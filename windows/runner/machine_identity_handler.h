#pragma once

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <string>
#include <vector>
#include <sstream>
#include <iomanip>
#include <algorithm>

namespace machine_identity {

inline std::wstring ReadRegistryString(HKEY rootKey,
                                           const std::wstring& path,
                                           const std::wstring& valueName) {
  HKEY key;
  if (RegOpenKeyExW(rootKey, path.c_str(), 0, KEY_READ, &key) !=
      ERROR_SUCCESS) {
    return L"";
  }

  DWORD type = 0;
  DWORD dataSize = 0;
  if (RegQueryValueExW(key, valueName.c_str(), nullptr, &type, nullptr,
                         &dataSize) != ERROR_SUCCESS) {
    RegCloseKey(key);
    return L"";
  }

  if (type != REG_SZ && type != REG_EXPAND_SZ) {
    RegCloseKey(key);
    return L"";
  }

  std::vector<wchar_t> buffer(dataSize / sizeof(wchar_t) + 1, L'\0');
  if (RegQueryValueExW(key, valueName.c_str(), nullptr, nullptr,
                         reinterpret_cast<BYTE*>(buffer.data()), &dataSize) !=
      ERROR_SUCCESS) {
    RegCloseKey(key);
    return L"";
  }

  RegCloseKey(key);
  return std::wstring(buffer.data());
}

inline std::wstring TrimWhitespace(const std::wstring& input) {
  size_t start = input.find_first_not_of(L" \t\r\n");
  if (start == std::wstring::npos) return L"";
  size_t end = input.find_last_not_of(L" \t\r\n");
  return input.substr(start, end - start + 1);
}

inline std::wstring ToLower(const std::wstring& input) {
  std::wstring result = input;
  std::transform(result.begin(), result.end(), result.begin(), ::towlower);
  return result;
}

inline std::wstring QueryWmiString(const std::wstring& wmiClass,
                                       const std::wstring& propertyName) {
  SECURITY_ATTRIBUTES sa;
  sa.nLength = sizeof(SECURITY_ATTRIBUTES);
  sa.bInheritHandle = TRUE;
  sa.lpSecurityDescriptor = nullptr;

  HANDLE readPipe = nullptr;
  HANDLE writePipe = nullptr;

  if (!CreatePipe(&readPipe, &writePipe, &sa, 0)) {
    return L"";
  }

  SetHandleInformation(readPipe, HANDLE_FLAG_INHERIT, 0);

  STARTUPINFOW si = {sizeof(STARTUPINFOW)};
  PROCESS_INFORMATION pi = {};
  si.hStdError = writePipe;
  si.hStdOutput = writePipe;
  si.dwFlags = STARTF_USESTDHANDLES;

  std::wstring command =
      L"powershell -Command \"(Get-WmiObject -Class " + wmiClass +
      L")." + propertyName + L"\"";

  if (!CreateProcessW(nullptr, &command[0], nullptr, nullptr, FALSE,
                        CREATE_NO_WINDOW, nullptr, nullptr, &si, &pi)) {
    CloseHandle(readPipe);
    CloseHandle(writePipe);
    return L"";
  }

  CloseHandle(writePipe);

  std::wstring result;
  char buffer[4096];
  DWORD bytesRead;
  while (ReadFile(readPipe, buffer, sizeof(buffer) - 1, &bytesRead,
                    nullptr) &&
         bytesRead > 0) {
    buffer[bytesRead] = '\0';
    // Convert ANSI to wstring
    int wlen = MultiByteToWideChar(CP_ACP, 0, buffer, bytesRead,
                                     nullptr, 0);
    if (wlen > 0) {
      std::wstring wbuf(wlen, L'\0');
      MultiByteToWideChar(CP_ACP, 0, buffer, bytesRead,
                            wbuf.data(), wlen);
      result += wbuf;
    }
  }

  CloseHandle(readPipe);
  CloseHandle(pi.hProcess);
  CloseHandle(pi.hThread);

  return TrimWhitespace(result);
}

inline std::wstring GetMachineGuid() {
  return ReadRegistryString(
      HKEY_LOCAL_MACHINE,
      L"SOFTWARE\\Microsoft\\Cryptography",
      L"MachineGuid");
}

inline std::wstring GetWindowsProductId() {
  return ReadRegistryString(
      HKEY_LOCAL_MACHINE,
      L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
      L"ProductId");
}

inline std::wstring GetProcessorId() {
  return QueryWmiString(L"Win32_Processor", L"ProcessorId");
}

inline std::wstring GetBaseBoardSerial() {
  return QueryWmiString(L"Win32_BaseBoard", L"SerialNumber");
}

}  // namespace machine_identity
