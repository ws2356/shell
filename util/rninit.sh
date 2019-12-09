#!/bin/bash

set -e

npx react-native init "$@"

POSITIONAL=()
while [ "$#" -gt 0 ] ; do
  key="$1"
  case $key in
      --*)
      shift
      if [ "$#" -gt 0 ] && [[ "$1" =~ [^-] ]] ; then
        shift
      fi
      ;;
      *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

project_name="${POSITIONAL[0]}"

cd "$project_name"

try_add_gem() {
  name=$1
  if ! grep "$name" Gemfile >/dev/null; then
    bundle add --skip-install "$name"
  fi
}

add_shell_build_phase() {
  local project_name=$1
  local target_name=$2
  local script_name=$3
  local script_source=$4
  rb_code=$(
  cat <<EOF
require 'xcodeproj'
project_path = '${project_name}.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == '${target_name}' }
target == nil && exit
scripts = target.shell_script_build_phases()
scripts && scripts.find { |s| s.name == '${script_name}' } && exit
s = target.new_shell_script_build_phase()
s.name = '${script_name}'
s.shell_script = '${script_source}'
project.save
EOF
)
  local one_line
  one_line=$(echo "$rb_code" | tr '\n' ';')
  ruby -e "$one_line"
}

modify_app_delegate() {
  cat >"${project_name}/AppDelegate.h" <<'EOF'
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@end
EOF

  cat >"${project_name}/AppDelegate.m" <<'EOF'
#import "AppDelegate.h"
#import "KSAppContext.h"
#import "HomeViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // 初始化KSAppContext （创建一些全局对象，比如rctBridge）
  KSAppContext *ctx = [KSAppContext sharedInstance];
  [ctx setupWithLaunchOptions:launchOptions];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [HomeViewController new];
  UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:rootViewController];
  self.window.rootViewController = navigationVC;
  [self.window makeKeyAndVisible];
  return YES;
}
@end
EOF
}

create_src_codes() {
  test -d src || mkdir src
  cat >'src/KSAppContext.h' <<'EOF'
#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSAppContext : NSObject <RCTBridgeDelegate>

+ (instancetype) sharedInstance;

- (void) setupWithLaunchOptions: (NSDictionary *) launchOptions;

@property (nonatomic, strong, readonly) RCTBridge *rctBridge;

@end

NS_ASSUME_NONNULL_END
EOF

  cat >'src/KSAppContext.m' <<'EOF'
#import "KSAppContext.h"
#import <React/RCTBundleURLProvider.h>

@interface KSAppContext ()
@property (nonatomic, strong, readwrite) RCTBridge *rctBridge;
@end

@implementation KSAppContext

+ (instancetype) sharedInstance {
  static dispatch_once_t onceToken;
  static KSAppContext *instance = nil;
  dispatch_once(&onceToken, ^{
    instance = [[KSAppContext alloc] init];
  });
  return instance;
}

- (void) setupWithLaunchOptions: (NSDictionary* )launchOptions {
  KSAppContext *ctx = [KSAppContext sharedInstance];
  ctx.rctBridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
}

# pragma mark - RCTBridgeDelegate
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}
@end
EOF

  cat >'src/BaseViewController.h' <<'EOF'
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
EOF

  cat >'src/BaseViewController.m' <<'EOF'
#import "BaseViewController.h"

@implementation BaseViewController
@end
EOF

  cat >'src/HomeViewController.h' <<'EOF'
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : BaseViewController

@end

NS_ASSUME_NONNULL_END
EOF

  cat >'src/HomeViewController.m' <<EOF
#import "HomeViewController.h"
#import "DynamicViewController.h"

@implementation HomeViewController
- (void)viewDidLoad {
  [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.bounds = [UIScreen mainScreen].bounds;
  self.view.backgroundColor = [UIColor whiteColor];
  self.title = @"Welcom to ${project_name}";
  
  UIButton *dynamicBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
  dynamicBtn.frame = CGRectMake(100, 100, 100, 60);
  [self.view addSubview:dynamicBtn];
  [dynamicBtn addTarget:self action:@selector(navigate:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) navigate: (UIButton *)sender {
  DynamicViewController *vc = [DynamicViewController new];
  [self showViewController:vc sender:self];
}
@end
EOF

  cat >'src/DynamicViewController.h' <<'EOF'
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DynamicViewController : BaseViewController

@end

NS_ASSUME_NONNULL_END
EOF

  cat >'src/DynamicViewController.m' <<EOF
#import "DynamicViewController.h"
#import <React/RCTRootView.h>
#import "KSAppContext.h"

@implementation DynamicViewController
- (void) loadView {
  KSAppContext *ctx = [KSAppContext sharedInstance];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:ctx.rctBridge
                                                   moduleName:@"${project_name}"
                                            initialProperties:nil];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  rootView.bounds = [UIScreen mainScreen].bounds;
  self.view = rootView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"A dynamic vc rendering jsmodule: ${project_name}";
}

@end
EOF
}

add_src_codes() {
  local project_name=$1
  local target_name=$2
  local filename=$3
  rb_code=$(
  cat <<EOF
require 'xcodeproj'
project_path = '${project_name}.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.native_targets.find { |t| t.name == '${target_name}' }
src_group = project.groups.find { |g| g.name == 'src' } || project.new_group('src', 'src')
target == nil && exit
h_file = src_group.new_reference('${filename}.h')
m_file = src_group.new_reference('${filename}.m')
target.add_file_references([h_file, m_file])
project.save
EOF
)
  local one_line
  one_line=$(echo "$rb_code" | tr '\n' ';')
  ruby -e "$one_line"
}

set -ex
(
cd ios
create_src_codes

shopt -s nullglob
for ff in src/*.h ; do
  mod=$(basename "$ff" .h)
  add_src_codes "$project_name" "$project_name" "$mod"
done
modify_app_delegate
)

(
cd ios
add_shell_build_phase "$project_name" "$project_name" "SwiftLint" 'find "${SRCROOT}/src" -name "*.swift" | grep -E "." >/dev/null || exit 0 ; "${PODS_ROOT}/SwiftLint/swiftlint" --path "${SRCROOT}/src"'

test -f Gemfile || bundle init
gem_source_line_re='^[[:space:]]*source[[:space:]]*".+"$'
if grep -E "$gem_source_line_re" Gemfile>/dev/null ; then
  sed -i.bak -E 's/'"$gem_source_line_re"'/source "https:\/\/gems.ruby-china.com\/"/' Gemfile \
    && rm Gemfile.bak
else
  echo 'source "https://gems.ruby-china.com/"' >>Gemfile
fi
try_add_gem fastlane
try_add_gem xcodeproj
try_add_gem xcpretty
try_add_gem cocoapods
bundle install

target_pat='^target[[:space:]]'"'${project_name}'"'[[:space:]]do$'
sed -i.bak -E \
-e /"$target_pat"'/i\
use_frameworks! \
\
' \
-e /"$target_pat"'/a\
'"\ \ pod 'SwiftyJSON'"'\
'"\ \ pod 'PromisesSwift'"'\
'"\ \ pod 'UIImage+FBLAdditions', '~> 1.0'"'\
'"\ \ pod 'SwiftLint'"'\
' \
Podfile && rm Podfile.bak
bundle exec pod install
)

git init && git add . && git commit -m 'Init'
