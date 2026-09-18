#include "machine_identity_handler.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

static std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;

static std::string WideToUtf8(const std::wstring& input) {
  if (input.empty()) {
    return "";
  }
  int size = WideCharToMultiByte(CP_UTF8, 0, input.c_str(), -1, nullptr, 0,
                                 nullptr, nullptr);
  if (size <= 0) {
    return "";
  }
  std::string result(size, '\0');
  WideCharToMultiByte(CP_UTF8, 0, input.c_str(), -1, result.data(), size,
                      nullptr, nullptr);
  if (!result.empty()) {
    result.pop_back();
  }
  return result;
}

void RegisterMachineIdentityChannel(flutter::FlutterEngine* engine) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(),
      "viyan.machine.identity",
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        if (call.method_name() == "getMachineIdentifiers") {
          std::stringstream ss;
          ss << "{";
          ss << "\"machineGuid\":\""
             << WideToUtf8(machine_identity::ToLower(
                    machine_identity::GetMachineGuid()))
             << "\",";
          ss << "\"windowsId\":\""
             << WideToUtf8(machine_identity::ToLower(
                    machine_identity::GetWindowsProductId()))
             << "\",";
          ss << "\"processorId\":\""
             << WideToUtf8(machine_identity::ToLower(
                    machine_identity::GetProcessorId()))
             << "\",";
          ss << "\"baseBoardId\":\""
             << WideToUtf8(machine_identity::ToLower(
                    machine_identity::GetBaseBoardSerial()))
             << "\"";
          ss << "}";

          result->Success(flutter::EncodableValue(ss.str()));
        } else {
          result->NotImplemented();
        }
      });
}