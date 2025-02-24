import mss
import sys
import yaml
import os

config_path = "./config/config.yml"
if not os.path.exists(config_path):
    print(f"Error: config file ({config_path}) not found")
    sys.exit(1)

with open(config_path, "r", encoding="utf-8") as file:
    config = yaml.safe_load(file)

screenshot_path = config.get("misc").get("screenshot_path")

print(config)
print(screenshot_path)

if not screenshot_path:
    print("Error: path for screenshot is not set")
    sys.exit(1)

monitor_number = int(sys.argv[1])

with mss.mss() as sct:
    monitors = sct.monitors

    if monitor_number >= len(monitors):
        print("Error: wrong monitor number")
        sys.exit(1)
    print(screenshot_path)
    screenshot = sct.grab(monitors[monitor_number])
    mss.tools.to_png(screenshot.rgb, screenshot.size, output=screenshot_path)
