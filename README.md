# take2 v1

Universal injected iOS runtime inspector for apps you are authorized to test.

## Included
- Arabic floating HUD
- Smart discovery of numeric/boolean Objective-C properties
- Technical name + Arabic label + confidence level
- Local setter-based editing where a normal Objective-C setter exists
- Tabs for discovered features, editable values, value search, and watch
- Sensitive/auth/payment-related names are filtered

## Current v1 limitations
- Runtime discovery is Objective-C-visible objects reachable from the active UI tree.
- Search/Watch tabs currently show the discovered value catalog; iterative raw-memory scanning/refinement is intentionally not implemented in this baseline.
- Swift-only/C++ state and server-side values are not modified.
- No network interception, purchase bypass, server manipulation, or automated interaction.

## Build
export THEOS=$HOME/theos
cd take2
make clean
make FINALPACKAGE=1 -j1

Output dylib will be under .theos/obj/.../take2.dylib.
Inject/re-sign only applications you own or are authorized to test.
