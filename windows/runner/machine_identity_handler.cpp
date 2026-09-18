#include "machine_identity_handler.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <sstream>
#include <iomanip>

void RegisterMachineIdentityChannel(flutter::FlutterEngine* engine) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      engine->plugin_registrar()->messenger(),
      "viyan.machine.identity",
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "getMachineIdentifiers") {
          auto machineGuid = machine_identity::GetMachineGuid();
          auto windowsId = machine_identity::GetWindowsProductId();
          auto processorId = machine_identity::GetProcessorId();
          auto baseBoardId = machine_identity::GetBaseBoardSerial();

          std::stringstream ss;
          ss << "{";
          ss << "\"machineGuid\":\"" << machine_identity::ToLower(machineGuid) << "\",";
          ss << "\"windowsId\":\"" << machine_identity::ToLower(windowsId) << "\",";
          ss << "\"processorId\":\"" << machine_identity::ToLower(processorId) << "\",";
          ss << "\"baseBoardId\":\"" << machine_identity::ToLower(baseBoardId) << "\"";
          ss << "}";

          result->Success(flutter::EncodableValue(ss.str()));
        } else {
          result->NotImplemented();
        }
      });

  channel_ = std::move(channel);
}

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
