#import <Cocoa/Cocoa.h>

int main(int argc, const char* argv[])
{
    printf(
        "In order to properly debug the Unit Tests with the TestTheTestTool,\n"
        "you'll need to make some changes to the TestTheTestTool executable (in\n"
        "the Executables section of the project explorer in Xcode.)\n"
        "\n"
        "Add this argument:\n"
        "  -SenTest All\n"
        "\n"
        "Set these variables in the executable's environment:\n"
        "  DYLD_INSERT_LIBRARIES=$(DEVELOPER_LIBRARY_DIR)/PrivateFrameworks/DevToolsBundleInjection.framework/DevToolsBundleInjection\n"
        "  DYLD_FALLBACK_FRAMEWORK_PATH=$(DEVELOPER_LIBRARY_DIR)/Frameworks\n"
        "  XCInjectBundle=Unit Tests.octest\n"
        "  XCInjectBundleInto=TestTheTestTool\n"
    );
}