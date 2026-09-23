// tweak.mm – Treasure Hunter Custom Cheat Menu
// Auto Dig, Avoid Mobs, Attack Mobs, Avoid Boss, Auto HP, Auto Revive, Auto Equip, Camera Zoom
// Sub-tab horizontal layout inside Auto tab – No ScrollView overlapping toggles
// Copyright (c) 2026

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <setjmp.h>
#import <signal.h>
#import <objc/runtime.h>
#import <unistd.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Security/Security.h>
#include <vector>
#include <string>

#define LICENSE_API_URL @"https://script.google.com/macros/s/AKfycbyNJMv06-cA6jO1-k8I3L1Tsm9QMTQId7FONhOqcg9xj1m6mR2WEbPgFxXj-FCDc2wG/exec"

// =============================================
// IL2CPP Function Pointers
// =============================================
namespace IL2CPP {
    void       *(*il2cpp_domain_get)();
    void      **(*il2cpp_domain_get_assemblies)(const void *domain, size_t *size);
    const void *(*il2cpp_assembly_get_image)(const void *assembly);
    uint32_t    (*il2cpp_image_get_class_count)(void *image);
    void       *(*il2cpp_image_get_class)(void *image, uint32_t index);
    void       *(*il2cpp_class_from_name)(const void *image, const char *ns, const char *name);
    const char *(*il2cpp_class_get_name)(void *klass);
    const char *(*il2cpp_class_get_namespace)(void *klass);
    void       *(*il2cpp_class_get_method_from_name)(void *klass, const char *name, int args);
    const void *(*il2cpp_class_get_type)(void *klass);
    void       *(*il2cpp_type_get_object)(const void *type);
    void       *(*il2cpp_class_get_parent)(void *klass);
    void       *(*il2cpp_class_get_field_from_name)(void *klass, const char *name);
    size_t      (*il2cpp_field_get_offset)(void *field);
    void        (*il2cpp_field_static_get_value)(void *field, void *value);
    void        (*il2cpp_field_static_set_value)(void *field, void *value);
    void       *(*il2cpp_string_new)(const char *str);
    void       *(*il2cpp_runtime_invoke)(void *method, void *obj, void **params, void **exc);
    void       *(*il2cpp_object_new)(void *klass);
    void       *(*il2cpp_domain_assembly_open)(void *domain, const char *name);
    void        (*il2cpp_runtime_class_init)(void *klass);
    void       *(*il2cpp_object_get_class)(void *obj);
    void       *(*il2cpp_class_get_methods)(void *klass, void **iter);
    const char *(*il2cpp_method_get_name)(void *method);
    const void *(*il2cpp_method_get_param)(void *method, int index);
    int         (*il2cpp_type_get_type)(const void *type);
    void       *(*il2cpp_class_from_type)(const void *type);
    void       *(*il2cpp_class_get_nested_types)(void *klass, void **iter);
}

static bool s_attached = false;
static sigjmp_buf  tls_jmpbuf;
static volatile int tls_in_safe = 0;

@class CADisplayLink;

// =============================================
// Forward declarations
// =============================================
@interface THTweakWindow : UIWindow
{
    // Main layout
    UIView *_panel;
    UISegmentedControl *_mainTabControl;   // "Auto" | "Cai dat"
    UIView *_autoPageView;
    UIView *_settingsPageView;
    UIView *_contactPageView;

    // Sub-tab inside Auto page: "Dao" | "Quai" | "PVP" | "HP/Song" | "Do"
    UISegmentedControl *_autoSubTabControl;
    UIView *_subDaoView;
    UIView *_subQuaiView;
    UIView *_subPvpView;
    UIView *_subHpView;
    UIView *_subDoView;

    // Dao sub-tab
    UISwitch *_swAutoDig;
    UILabel  *_lblDigRange;
    UISlider *_sliderDigRange;
    UILabel  *_lblDigStopDist;
    UISlider *_sliderDigStopDist;
    UILabel  *_lblSpeedSensitivity;
    UISlider *_sliderSpeedSensitivity;
    UISwitch *_swLockDigPos;
    UILabel  *_lblLockDigRange;
    UISlider *_sliderLockDigRange;
    UIView   *_rowLockDigRange;

    // Quai sub-tab
    UISwitch *_swAttackMobs;
    UILabel  *_lblAttackRange;
    UISlider *_sliderAttackRange;
    UISwitch *_swMobFilterEnabled;
    UIButton *_btnMobCategory;
    
    UISwitch *_swAvoidMobs;
    UILabel  *_lblAvoidRange;
    UISlider *_sliderAvoidRange;
    UISwitch *_swAvoidMobFilterEnabled;
    UIButton *_btnAvoidMobCategory;
    UISwitch *_swAvoidBoss;

    // PVP / Ne nguoi choi sub-tab
    UISwitch *_swAvoidPlayers;
    UILabel  *_lblAvoidPlayerRange;
    UISlider *_sliderAvoidPlayerRange;
    UISwitch *_swAutoQuitPlayer;
    UILabel  *_lblAutoQuitPlayerRange;
    UISlider *_sliderAutoQuitPlayerRange;

    // HP/Song sub-tab
    UISwitch *_swAutoHp;
    UILabel  *_lblHpPercent;
    UISlider *_sliderHpPercent;
    UISwitch *_swAutoRevive;

    // Do sub-tab
    UISwitch *_swAutoEquip;
    UISegmentedControl *_segEquipQuality;
    UISwitch *_swAutoSellKey;
    UISwitch *_swAutoSellIngredient;
    UISegmentedControl *_segSellIngredientQuality;
    UISwitch *_swRecipeMerge;
    UISwitch *_swRecipeMergeGoToFire;
    UIButton *_btnRecipeInput;
    UILabel  *_lblRecipeInfo;
    UISwitch *_swAutoMergeIngredient;
    UISegmentedControl *_segMergeIngredientQuality;

    // Settings page
    UISwitch *_swZoom;
    UILabel  *_lblZoomValue;
    UISlider *_sliderZoom;
    UISwitch *_swShowRangeCircles;
    UISwitch *_swShowFps;
    UISwitch *_swAutoWatchAds;

    UILabel *_lblStatus;
    CADisplayLink *_displayLink;
    UILabel *_lblEspText;
    UILabel *_lblFpsBadge;
    UILabel *_lblMobMinHp;
    UISlider *_sliderMobMinHp;
    UILabel *_lblMobMaxHp;
    UISlider *_sliderMobMaxHp;
    
    // Range visualization shape layers
    CAShapeLayer *_digRangeLayer;
    CAShapeLayer *_lockDigRangeLayer;
    CAShapeLayer *_attackRangeLayer;
    CAShapeLayer *_mobAvoidRangeLayer;
    CAShapeLayer *_playerAvoidRangeLayer;
    CAShapeLayer *_autoQuitRangeLayer;
}
- (void)setStatusText:(NSString *)text;
- (void)updateESPLine;
- (void)mainTabChanged:(UISegmentedControl *)sender;
- (void)autoSubTabChanged:(UISegmentedControl *)sender;
- (void)togglePanel:(UIButton *)sender;
- (void)drag:(UIPanGestureRecognizer *)sender;
- (void)openFacebook:(id)sender;
- (void)openTelegram:(id)sender;
- (void)openYoutube:(id)sender;
- (void)openGroupTelegram:(id)sender;
- (void)attachWindowSceneIfNeeded;
- (void)showMobFilterDialogForMode:(BOOL)isAvoidMode;
- (void)dismissMobCategoryDialog;
- (void)mobCategoryItemSelected:(UIButton *)sender;
- (void)showCustomMobIdInputDialogForMode:(BOOL)isAvoidMode;
- (void)swAutoSellKeyChanged:(UISwitch *)sender;
- (void)swRecipeMergeChanged:(UISwitch *)sender;
- (void)swRecipeMergeGoToFireChanged:(UISwitch *)sender;
- (void)btnRecipeInputPressed:(id)sender;
- (void)btnClearRecipePressed:(id)sender;
- (void)showRecipeInputDialog;
- (void)applyRecipeBase64String:(NSString *)inputStr;
- (void)updateRecipeInfoLabel;
@end

static THTweakWindow *g_window = nil;
@class THActivationWindow;
static THActivationWindow *g_activationWindow = nil;

// =============================================
// Utility helpers
// =============================================
static UIWindowScene* GetActiveWindowScene() {
    if (@available(iOS 13.0, *)) {
        UIApplication *app = [UIApplication sharedApplication];
        if ([app respondsToSelector:@selector(connectedScenes)]) {
            NSSet *scenes = [app connectedScenes];
            for (UIScene *scene in scenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    if (scene.activationState == UISceneActivationStateForegroundActive) {
                        return (UIWindowScene *)scene;
                    }
                }
            }
            for (UIScene *scene in scenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    if (scene.activationState == UISceneActivationStateForegroundInactive) {
                        return (UIWindowScene *)scene;
                    }
                }
            }
            for (UIScene *scene in scenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    return (UIWindowScene *)scene;
                }
            }
        }
    }
    return nil;
}

static void *ScanFindClass(const char *targetNs, const char *targetName);
static void *FindMethodInHierarchy(void *klass, const char *name, int args);

static void safe_sig_handler(int sig) {
    if (tls_in_safe) {
        tls_in_safe = 0;
        sigset_t unblock;
        sigemptyset(&unblock);
        sigaddset(&unblock, SIGSEGV);
        sigaddset(&unblock, SIGBUS);
        pthread_sigmask(SIG_UNBLOCK, &unblock, nullptr);
        siglongjmp(tls_jmpbuf, sig);
    }
    signal(sig, SIG_DFL);
    raise(sig);
}
static void InstallSafeSignalHandlers() {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = safe_sig_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGSEGV, &sa, nullptr);
    sigaction(SIGBUS,  &sa, nullptr);
}

static int MyWcslen(const wchar_t* s) {
    if (!s) return 0;
    int len = 0;
    while (s[len] != L'\0') len++;
    return len;
}
static bool WideStringContains(const wchar_t* src, int32_t len, const wchar_t* search) {
    if (!src || len <= 0 || !search) return false;
    int searchLen = MyWcslen(search);
    if (searchLen == 0 || searchLen > len) return false;
    for (int i = 0; i <= len - searchLen; i++) {
        bool match = true;
        for (int j = 0; j < searchLen; j++) {
            wchar_t c1 = src[i+j]; wchar_t c2 = search[j];
            if (c1>='A'&&c1<='Z') c1=c1-'A'+'a';
            if (c2>='A'&&c2<='Z') c2=c2-'A'+'a';
            if (c1 != c2) { match=false; break; }
        }
        if (match) return true;
    }
    return false;
}

static inline bool IsValidUnityObj(void* obj) {
    if (!obj) return false;
    return *(void**)((uint8_t*)obj + 0x10) != nullptr;
}

// =============================================
// IL2CPP Dynamic Resolution
// =============================================
static void Il2CppAttach() {
    if (s_attached) return;
    void *handle = dlopen(NULL, RTLD_LAZY | RTLD_GLOBAL);
    if (!handle) return;
#define BIND(fn) IL2CPP::fn = reinterpret_cast<decltype(IL2CPP::fn)>(dlsym(handle, #fn))
    BIND(il2cpp_domain_get); BIND(il2cpp_domain_get_assemblies); BIND(il2cpp_assembly_get_image);
    BIND(il2cpp_image_get_class_count); BIND(il2cpp_image_get_class); BIND(il2cpp_class_from_name);
    BIND(il2cpp_class_get_name); BIND(il2cpp_class_get_namespace); BIND(il2cpp_class_get_method_from_name);
    BIND(il2cpp_class_get_type); BIND(il2cpp_type_get_object); BIND(il2cpp_class_get_parent);
    BIND(il2cpp_class_get_field_from_name); BIND(il2cpp_field_get_offset);
    BIND(il2cpp_field_static_get_value); BIND(il2cpp_field_static_set_value);
    BIND(il2cpp_string_new); BIND(il2cpp_runtime_invoke); BIND(il2cpp_object_new);
    BIND(il2cpp_domain_assembly_open); BIND(il2cpp_runtime_class_init); BIND(il2cpp_object_get_class);
    BIND(il2cpp_class_get_methods); BIND(il2cpp_method_get_name); BIND(il2cpp_method_get_param); BIND(il2cpp_type_get_type);
    BIND(il2cpp_class_from_type);
    if (dlsym(handle, "il2cpp_class_get_nested_types"))
        IL2CPP::il2cpp_class_get_nested_types = reinterpret_cast<decltype(IL2CPP::il2cpp_class_get_nested_types)>(dlsym(handle, "il2cpp_class_get_nested_types"));
#undef BIND
    s_attached = true;
}

static void *ScanFindClass(const char *targetNs, const char *targetName) {
    if (!s_attached) return nullptr;
    void *domain = IL2CPP::il2cpp_domain_get();
    if (!domain) return nullptr;
    size_t asmCount = 0;
    void **assemblies = IL2CPP::il2cpp_domain_get_assemblies(domain, &asmCount);
    if (!assemblies || asmCount == 0) return nullptr;
    for (size_t ai = 0; ai < asmCount; ai++) {
        void *img = (void *)IL2CPP::il2cpp_assembly_get_image(assemblies[ai]);
        if (!img) continue;
        if (IL2CPP::il2cpp_class_from_name) {
            void *klass = IL2CPP::il2cpp_class_from_name(img, targetNs, targetName);
            if (klass) return klass;
        }
        if (!IL2CPP::il2cpp_image_get_class_count || !IL2CPP::il2cpp_image_get_class) continue;
        uint32_t classCount = IL2CPP::il2cpp_image_get_class_count(img);
        for (uint32_t ci = 0; ci < classCount; ci++) {
            void *klass = IL2CPP::il2cpp_image_get_class(img, ci);
            if (!klass) continue;
            const char *ns   = IL2CPP::il2cpp_class_get_namespace(klass);
            const char *name = IL2CPP::il2cpp_class_get_name(klass);
            if (!name) continue;
            const char *safeNs = ns ? ns : "";
            if (strcmp(safeNs, targetNs)==0 && strcmp(name, targetName)==0) return klass;
        }
    }
    return nullptr;
}

static void *FindMethodInHierarchy(void *klass, const char *name, int args) {
    if (!klass || !IL2CPP::il2cpp_class_get_method_from_name) return nullptr;
    void *mi = IL2CPP::il2cpp_class_get_method_from_name(klass, name, args);
    if (mi) return mi;
    if (IL2CPP::il2cpp_class_get_parent) {
        void *parent = IL2CPP::il2cpp_class_get_parent(klass);
        while (parent) {
            mi = IL2CPP::il2cpp_class_get_method_from_name(parent, name, args);
            if (mi) return mi;
            parent = IL2CPP::il2cpp_class_get_parent(parent);
        }
    }
    return nullptr;
}

static void *s_unityObjectClass = nullptr;
static void *s_findObjectsMI    = nullptr;
static void EnsureFindObjectsMethod() {
    if (s_findObjectsMI) return;
    if (!s_unityObjectClass) s_unityObjectClass = ScanFindClass("UnityEngine", "Object");
    if (s_unityObjectClass)
        s_findObjectsMI = IL2CPP::il2cpp_class_get_method_from_name(s_unityObjectClass, "FindObjectsOfType", 1);
}
static void *Il2cppFindObjects(void *klass, int32_t *outCount) {
    *outCount = 0;
    if (!klass) return nullptr;
    if (!IL2CPP::il2cpp_class_get_type || !IL2CPP::il2cpp_type_get_object) return nullptr;
    EnsureFindObjectsMethod();
    if (!s_findObjectsMI || !IL2CPP::il2cpp_runtime_invoke) return nullptr;
    const void *il2type = IL2CPP::il2cpp_class_get_type(klass);
    if (!il2type) return nullptr;
    void *typeObj = IL2CPP::il2cpp_type_get_object(il2type);
    if (!typeObj) return nullptr;
    void *arr = nullptr;
    tls_in_safe = 1;
    if (sigsetjmp(tls_jmpbuf, 1) == 0) {
        void* params[1]; params[0] = typeObj;
        void* exc = nullptr;
        arr = IL2CPP::il2cpp_runtime_invoke(s_findObjectsMI, nullptr, params, &exc);
        tls_in_safe = 0;
    } else {
        tls_in_safe = 0;
        InstallSafeSignalHandlers();
        return nullptr;
    }
    if (!arr) return nullptr;
    *outCount = *(int32_t *)((uint8_t *)arr + 0x18);
    return arr;
}
static void *GetArrElem(void *arr, int32_t index) {
    if (!arr || index < 0) return nullptr;
    return *((void **)((uint8_t *)arr + 0x20) + index);
}
static void* SafeInvoke(void* methodInfo, void* obj, void** params) {
    if (!methodInfo || !IL2CPP::il2cpp_runtime_invoke) return nullptr;
    void* exc = nullptr; void* ret = nullptr;
    tls_in_safe = 1;
    if (sigsetjmp(tls_jmpbuf, 1) == 0) {
        ret = IL2CPP::il2cpp_runtime_invoke(methodInfo, obj, params, &exc);
        tls_in_safe = 0;
    } else {
        tls_in_safe = 0;
        InstallSafeSignalHandlers();
    }
    return ret;
}

struct Vector3 { float x, y, z; };
struct Vector2 { float x, y; };

// =============================================
// Game State Variables
// =============================================
static bool  g_autoDig         = false;
static bool  g_autoAvoidMobs   = false;
static bool  g_autoAttackMobs  = false;
static bool  g_avoidBoss       = false;
static bool  g_autoHp          = false;
static bool  g_autoRevive      = false;
static bool  g_returnToDeathPos = false;
static Vector3 g_deathPos      = {0,0,0};
static bool    g_hasDeathPos   = false;
static bool    g_wasDead       = false;
static bool  g_autoEquip       = false;
static bool    g_menuMasterSwitch = true;
static bool    g_attackMobFilterMin = false;
static bool    g_attackMobFilterMax = false;
static float   g_attackMobMinHp     = 20.0f;
static float   g_attackMobMaxHp     = 500.0f;
static bool  g_cameraZoomOn    = false;

static float   g_digRangeValue        = 10.0f;
static float   g_digStopDist          = 0.15f;
static float   g_speedSensitivity     = 1.0f;
static float   g_avoidRangeValue      = 5.0f;
static float   g_attackRangeValue = 10.0f;
static float   g_autoHpPercent    = 0.70f;
static int32_t g_autoEquipQuality = 2;
static float   g_cameraZoomValue  = 8.0f;
static bool    g_showFps          = true;
static bool    g_autoWatchAds     = false;
static double  s_lastAutoAdTime   = 0.0;

static bool    g_lockDigPos       = false;
static bool    g_hasLockedPos     = false;
static Vector3 g_lockedDigPos     = {0,0,0};
static float   g_lockedDigRange   = 5.0f;

static bool    g_autoSellKey                = false;

static bool    g_autoSellIngredient        = false;
static int32_t g_autoSellIngredientQuality = 0; // 0: Thường, 1: Hiếm, 2: Tím, 3: Cam

static bool    g_autoMergeIngredient        = false;
static int32_t g_autoMergeIngredientQuality = 2; // 0: Thường, 1: Hiếm, 2: Tím, 3: Cam (Ghép đá đến phẩm chất)

// Auto Merge Recipe (shiuliuliu.github.io/treasurehunter/web/)
struct RecipeStone {
    int  rareType; // 0: Common, 1: Rare, 2: Epic, 3: Legendary
    int  level;
    bool isGroup;
    int  id;       // itemId if !isGroup, groupId if isGroup
};

struct RecipeGroup {
    int id;
    std::vector<int> itemIds;
};

struct RecipeFormula {
    int goldNeed;
    int diamondNeed;
    std::vector<RecipeStone> stones;
};

struct RecipeData {
    std::string name;
    std::vector<RecipeGroup> groups;
    std::vector<RecipeFormula> formulas;
    bool valid = false;
};

static bool        g_recipeMergeEnabled    = false;
static bool        g_recipeMergeGoToFire   = true;
static bool        g_isGoingToFire         = false;
static bool        g_isAtFireForRecipe     = false;
static Vector3     g_farmPosBeforeFire     = {0,0,0};
static bool        g_hasFarmPosBeforeFire  = false;
static bool        g_isReturningToFarm     = false;
static NSString*   g_recipeBase64          = @"";
static RecipeData  g_currentRecipe;

struct RecipeMatcher {
    struct InvStoneItem {
        void*   strId;
        int32_t itemId;
        int32_t level;
        int32_t rareType;
    };

    static bool Dfs(size_t reqIdx,
                    const std::vector<RecipeStone>& reqStones,
                    const std::vector<InvStoneItem>& invStones,
                    const std::vector<RecipeGroup>& groups,
                    std::vector<bool>& used,
                    std::vector<void*>& matchedIds) {
        if (reqIdx >= reqStones.size()) return true;
        const auto& req = reqStones[reqIdx];
        for (size_t i = 0; i < invStones.size(); i++) {
            if (used[i]) continue;
            if (invStones[i].rareType != req.rareType) continue;
            if (invStones[i].level != req.level) continue;
            if (!req.isGroup) {
                if (invStones[i].itemId != req.id) continue;
            } else {
                bool foundInGroup = false;
                for (const auto& grp : groups) {
                    if (grp.id == req.id) {
                        for (int gid : grp.itemIds) {
                            if (invStones[i].itemId == gid) {
                                foundInGroup = true;
                                break;
                            }
                        }
                        break;
                    }
                }
                if (!foundInGroup) continue;
            }

            used[i] = true;
            matchedIds.push_back(invStones[i].strId);
            if (Dfs(reqIdx + 1, reqStones, invStones, groups, used, matchedIds)) return true;
            matchedIds.pop_back();
            used[i] = false;
        }
        return false;
    }
};

static bool ParseRecipeData(NSData *data, RecipeData &outRecipe) {
    outRecipe = RecipeData();
    if (!data || [data length] < 4) return false;
    const uint8_t *bytes = (const uint8_t *)[data bytes];
    size_t len = [data length];
    size_t offset = 0;

    auto readU8 = [&](uint8_t &val) -> bool {
        if (offset + 1 > len) return false;
        val = bytes[offset++];
        return true;
    };

    auto readU16BE = [&](uint16_t &val) -> bool {
        if (offset + 2 > len) return false;
        val = ((uint16_t)bytes[offset] << 8) | (uint16_t)bytes[offset + 1];
        offset += 2;
        return true;
    };

    // 1. Name
    uint16_t nameLen = 0;
    if (!readU16BE(nameLen)) return false;
    if (offset + nameLen > len) return false;
    if (nameLen > 0) {
        outRecipe.name = std::string((const char*)(bytes + offset), nameLen);
        offset += nameLen;
    } else {
        outRecipe.name = "Công thức";
    }

    // 2. Groups
    uint8_t numGroups = 0;
    if (!readU8(numGroups)) return false;
    for (int g = 0; g < (int)numGroups; g++) {
        RecipeGroup group;
        uint8_t gid = 0, idCount = 0;
        if (!readU8(gid)) return false;
        if (!readU8(idCount)) return false;
        group.id = gid;
        for (int i = 0; i < (int)idCount; i++) {
            uint16_t itemId = 0;
            if (!readU16BE(itemId)) return false;
            group.itemIds.push_back(itemId);
        }
        outRecipe.groups.push_back(group);
    }

    // 3. Formulas
    uint8_t numFormulas = 0;
    if (!readU8(numFormulas)) return false;
    for (int f = 0; f < (int)numFormulas; f++) {
        RecipeFormula formula;
        uint16_t gold = 0, dia = 0;
        uint8_t stoneCount = 0;
        if (!readU16BE(gold)) return false;
        if (!readU16BE(dia)) return false;
        if (!readU8(stoneCount)) return false;
        formula.goldNeed = gold;
        formula.diamondNeed = dia;
        for (int s = 0; s < (int)stoneCount; s++) {
            uint8_t packed = 0;
            uint16_t sid = 0;
            if (!readU8(packed)) return false;
            if (!readU16BE(sid)) return false;
            RecipeStone st;
            st.rareType = packed & 3;
            st.level = (packed >> 2) & 31;
            st.isGroup = ((packed >> 7) & 1) != 0;
            st.id = sid;
            formula.stones.push_back(st);
        }
        outRecipe.formulas.push_back(formula);
    }

    outRecipe.valid = (outRecipe.formulas.size() > 0);
    return outRecipe.valid;
}

static bool CheckIfRecipeFormulaReady(void* playerObj, std::vector<void*>* outMatchedIds) {
    if (!playerObj || !g_currentRecipe.valid || g_currentRecipe.formulas.empty()) return false;
    void* ingredientObj = *(void**)((uint8_t*)playerObj + 0x320); // characterIngredient
    if (!ingredientObj) return false;
    void* listObj = *(void**)((uint8_t*)ingredientObj + 0x80); // localEquipments
    if (!listObj) return false;
    void* arr = *(void**)((uint8_t*)listObj + 0x10);
    int32_t size = *(int32_t*)((uint8_t*)listObj + 0x18);
    if (!arr || size <= 0) return false;

    std::vector<RecipeMatcher::InvStoneItem> availableStones;
    availableStones.reserve(size);
    int invRareCount[4] = {0, 0, 0, 0};
    for (int i = 0; i < size; i++) {
        void* item = *((void**)((uint8_t*)arr + 0x20) + i);
        if (!item) continue;
        bool isLock = *(bool*)((uint8_t*)item + 0x38);
        if (isLock) continue;
        void* idStr = *(void**)((uint8_t*)item + 0x10);
        if (!idStr) continue;
        int32_t r = *(int32_t*)((uint8_t*)item + 0x28);
        int32_t id = *(int32_t*)((uint8_t*)item + 0x18);
        int32_t lvl = *(int32_t*)((uint8_t*)item + 0x1c);
        if (r >= 0 && r < 4) invRareCount[r]++;
        availableStones.push_back({ idStr, id, lvl, r });
    }

    for (const auto& formula : g_currentRecipe.formulas) {
        if (formula.stones.empty()) continue;
        if (availableStones.size() < formula.stones.size()) continue;

        int reqRareCount[4] = {0, 0, 0, 0};
        for (const auto& s : formula.stones) {
            if (s.rareType >= 0 && s.rareType < 4) reqRareCount[s.rareType]++;
        }
        bool enoughRare = true;
        for (int r = 0; r < 4; r++) {
            if (invRareCount[r] < reqRareCount[r]) { enoughRare = false; break; }
        }
        if (!enoughRare) continue;

        std::vector<bool> used(availableStones.size(), false);
        std::vector<void*> matchedIds;
        matchedIds.reserve(formula.stones.size());

        if (RecipeMatcher::Dfs(0, formula.stones, availableStones, g_currentRecipe.groups, used, matchedIds) &&
            matchedIds.size() == formula.stones.size()) {
            if (outMatchedIds) *outMatchedIds = matchedIds;
            return true;
        }
    }
    return false;
}

static void* GetMergeIngredientMethod(void* pbKlass) {
    static void* s_targetMergeMI = nullptr;
    if (s_targetMergeMI) return s_targetMergeMI;
    if (!pbKlass) pbKlass = ScanFindClass("", "PlayerBehavior");
    if (pbKlass) {
        // CmdMergeIngredient directly transmits the Mirror [Command] RPC packet to the server
        s_targetMergeMI = FindMethodInHierarchy(pbKlass, "CmdMergeIngredient", 2);
        if (!s_targetMergeMI)
            s_targetMergeMI = FindMethodInHierarchy(pbKlass, "RequestMergeIngredient", 2);
        if (!s_targetMergeMI)
            s_targetMergeMI = FindMethodInHierarchy(pbKlass, "CmdAutoMergeIngredient", 2);
        if (!s_targetMergeMI)
            s_targetMergeMI = FindMethodInHierarchy(pbKlass, "RequesAutoMergeIngredient", 2);
    }
    return s_targetMergeMI;
}

static bool InvokeMergeIngredient(void* playerObj, void* listObj, int32_t apiToken) {
    if (!playerObj || !listObj) return false;
    static void* pbKlass = nullptr;
    if (!pbKlass) pbKlass = ScanFindClass("", "PlayerBehavior");
    if (!pbKlass) return false;

    static void* s_cmdMergeMI = nullptr;
    static void* s_reqMergeMI = nullptr;
    static void* s_cmdAutoMI  = nullptr;
    static void* s_reqAutoMI  = nullptr;
    static bool s_resolved = false;
    if (!s_resolved) {
        s_cmdMergeMI = FindMethodInHierarchy(pbKlass, "CmdMergeIngredient", 2);
        s_reqMergeMI = FindMethodInHierarchy(pbKlass, "RequestMergeIngredient", 2);
        s_cmdAutoMI  = FindMethodInHierarchy(pbKlass, "CmdAutoMergeIngredient", 2);
        s_reqAutoMI  = FindMethodInHierarchy(pbKlass, "RequesAutoMergeIngredient", 2);
        s_resolved = true;
    }

    void* params[2] = { listObj, &apiToken };
    bool sent = false;

    // 1. Direct Mirror Command RPC transmission to server
    if (s_cmdMergeMI) {
        SafeInvoke(s_cmdMergeMI, playerObj, params);
        sent = true;
    }
    // 2. Also trigger client-side method
    if (s_reqMergeMI) {
        SafeInvoke(s_reqMergeMI, playerObj, params);
        sent = true;
    }
    // 3. Fallbacks if neither CmdMerge nor RequestMerge existed
    if (!sent) {
        if (s_cmdAutoMI) {
            SafeInvoke(s_cmdAutoMI, playerObj, params);
            sent = true;
        }
        if (s_reqAutoMI) {
            SafeInvoke(s_reqAutoMI, playerObj, params);
            sent = true;
        }
    }
    return sent;
}

static void* CreateIl2CppStringList(const std::vector<void*>& stringIds, void* playerObj, void* methodInfo) {
    static void* s_listStringKlass = nullptr;
    static void* s_listStringCtor = nullptr;
    static void* s_listStringAdd = nullptr;

    if (!s_listStringKlass) {
        // 1. Try from methodInfo parameter 0
        if (methodInfo && IL2CPP::il2cpp_method_get_param && IL2CPP::il2cpp_class_from_type) {
            const void* pType = IL2CPP::il2cpp_method_get_param(methodInfo, 0);
            if (pType) {
                s_listStringKlass = (void*)IL2CPP::il2cpp_class_from_type(pType);
            }
        }

        // 2. Fallback: Try from playerObj's existing List<string> fields
        if (!s_listStringKlass && playerObj) {
            void* ex = *(void**)((uint8_t*)playerObj + 0x398); // currenOrderIds
            if (!ex) ex = *(void**)((uint8_t*)playerObj + 0x430); // activationCodes
            if (!ex) ex = *(void**)((uint8_t*)playerObj + 0x438); // claimedSocialRewards
            if (ex && IsValidUnityObj(ex)) {
                s_listStringKlass = *(void**)ex; // Il2CppObject::klass
            }
        }
    }

    if (s_listStringKlass) {
        if (IL2CPP::il2cpp_runtime_class_init) {
            IL2CPP::il2cpp_runtime_class_init(s_listStringKlass);
        }

        if (!s_listStringCtor) s_listStringCtor = FindMethodInHierarchy(s_listStringKlass, ".ctor", 0);
        if (!s_listStringAdd)  s_listStringAdd  = FindMethodInHierarchy(s_listStringKlass, "Add", 1);

        if ((!s_listStringCtor || !s_listStringAdd) && IL2CPP::il2cpp_class_get_methods) {
            void* iter = nullptr;
            while (void* m = IL2CPP::il2cpp_class_get_methods(s_listStringKlass, &iter)) {
                const char* mn = IL2CPP::il2cpp_method_get_name ? IL2CPP::il2cpp_method_get_name(m) : nullptr;
                if (mn) {
                    if (!s_listStringCtor && strcmp(mn, ".ctor") == 0) s_listStringCtor = m;
                    if (!s_listStringAdd && strcmp(mn, "Add") == 0) s_listStringAdd = m;
                }
            }
        }
    }

    if (!s_listStringKlass || !IL2CPP::il2cpp_object_new) return nullptr;

    void* listObj = IL2CPP::il2cpp_object_new(s_listStringKlass);
    if (!listObj) return nullptr;

    if (s_listStringCtor) {
        SafeInvoke(s_listStringCtor, listObj, nullptr);
    }

    if (s_listStringAdd) {
        for (void* sId : stringIds) {
            if (sId) {
                void* p[1] = { sId };
                SafeInvoke(s_listStringAdd, listObj, p);
            }
        }
    }

    return listObj;
}

static bool GetClosestFireCraftPosition(Vector3 playerPos, Vector3* outClosestFire, float* outDist) {
    if (!outClosestFire) return false;

    static void* mapManagerKlass = nullptr;
    static void* mmInstanceField = nullptr;
    static size_t fireCraftLocOffset = 0;
    static bool offsetResolved = false;

    if (!mapManagerKlass) mapManagerKlass = ScanFindClass("", "MapManager");
    if (mapManagerKlass) {
        if (!mmInstanceField)
            mmInstanceField = IL2CPP::il2cpp_class_get_field_from_name(mapManagerKlass, "instance");
        if (!offsetResolved) {
            void* field = IL2CPP::il2cpp_class_get_field_from_name(mapManagerKlass, "FireCraftLocation");
            if (field && IL2CPP::il2cpp_field_get_offset) {
                fireCraftLocOffset = IL2CPP::il2cpp_field_get_offset(field);
            } else {
                fireCraftLocOffset = 0x128; // Fallback from dump.cs
            }
            offsetResolved = true;
        }
    }

    void* mmInstance = nullptr;
    if (mmInstanceField && IL2CPP::il2cpp_field_static_get_value) {
        IL2CPP::il2cpp_field_static_get_value(mmInstanceField, &mmInstance);
    }

    if (mmInstance && IsValidUnityObj(mmInstance)) {
        void* fireCraftList = *(void**)((uint8_t*)mmInstance + fireCraftLocOffset);
        if (fireCraftList) {
            void* arr = *(void**)((uint8_t*)fireCraftList + 0x10);
            int32_t size = *(int32_t*)((uint8_t*)fireCraftList + 0x18);
            if (arr && size > 0) {
                float bestDist = 999999.0f;
                Vector3 bestPos = {0,0,0};
                bool found = false;

                for (int i = 0; i < size; i++) {
                    Vector3* pPos = (Vector3*)((uint8_t*)arr + 0x20 + i * sizeof(Vector3));
                    float dx = pPos->x - playerPos.x;
                    float dy = pPos->y - playerPos.y;
                    float dist = sqrtf(dx * dx + dy * dy);
                    if (dist < bestDist) {
                        bestDist = dist;
                        bestPos = *pPos;
                        found = true;
                    }
                }

                if (found) {
                    *outClosestFire = bestPos;
                    if (outDist) *outDist = bestDist;
                    return true;
                }
            }
        }
    }

    // 2. Scan scene MapObject with MapType::FireCraft (mapType == 4)
    static void* mapObjectKlass = nullptr;
    static void* compKlass = nullptr;
    static void* getTransformMI = nullptr;
    static void* transformKlass = nullptr;
    static void* getPositionMI = nullptr;
    if (!mapObjectKlass) mapObjectKlass = ScanFindClass("", "MapObject");
    if (!compKlass) compKlass = ScanFindClass("UnityEngine", "Component");
    if (compKlass && !getTransformMI) getTransformMI = FindMethodInHierarchy(compKlass, "get_transform", 0);
    if (!transformKlass) transformKlass = ScanFindClass("UnityEngine", "Transform");
    if (transformKlass && !getPositionMI) getPositionMI = FindMethodInHierarchy(transformKlass, "get_position", 0);

    if (mapObjectKlass && getTransformMI && getPositionMI) {
        int32_t mapCount = 0;
        void* mapArr = Il2cppFindObjects(mapObjectKlass, &mapCount);
        if (mapArr && mapCount > 0) {
            float bestDist = 999999.0f;
            Vector3 bestPos = {0,0,0};
            bool found = false;
            for (int i = 0; i < mapCount; i++) {
                void* mapObj = GetArrElem(mapArr, i);
                if (!mapObj || !IsValidUnityObj(mapObj)) continue;
                void* mapData = *(void**)((uint8_t*)mapObj + 0x20);
                if (!mapData) continue;
                int32_t mType = *(int32_t*)((uint8_t*)mapData + 0x18); // MapData.mapType
                if (mType == 4) { // MapType::FireCraft
                    void* trans = SafeInvoke(getTransformMI, mapObj, nullptr);
                    if (!trans) continue;
                    void* boxed = SafeInvoke(getPositionMI, trans, nullptr);
                    if (!boxed) continue;
                    Vector3 pos = *(Vector3*)((uint8_t*)boxed + 16);
                    float dx = pos.x - playerPos.x;
                    float dy = pos.y - playerPos.y;
                    float dist = sqrtf(dx * dx + dy * dy);
                    if (dist < bestDist) {
                        bestDist = dist;
                        bestPos = pos;
                        found = true;
                    }
                }
            }
            if (found) {
                *outClosestFire = bestPos;
                if (outDist) *outDist = bestDist;
                return true;
            }
        }
    }

    // 3. Fallback: NavigationManager (query at most once every 5 seconds to avoid spamming GoToFireCraft)
    static double lastNavFetchTime = 0;
    static Vector3 cachedNavTarget = {0,0,0};
    static bool hasCachedNavTarget = false;
    double nowNavTime = [[NSProcessInfo processInfo] systemUptime];

    if (!hasCachedNavTarget || nowNavTime - lastNavFetchTime > 5.0) {
        lastNavFetchTime = nowNavTime;
        static void* navManagerKlass = nullptr;
        static void* navInstanceField = nullptr;
        if (!navManagerKlass) navManagerKlass = ScanFindClass("", "NavigationManager");
        if (navManagerKlass && !navInstanceField)
            navInstanceField = IL2CPP::il2cpp_class_get_field_from_name(navManagerKlass, "Instance");

        void* navInstance = nullptr;
        if (navInstanceField && IL2CPP::il2cpp_field_static_get_value) {
            IL2CPP::il2cpp_field_static_get_value(navInstanceField, &navInstance);
        }
        if (navInstance && IsValidUnityObj(navInstance)) {
            static void* goToFireCraftMI = nullptr;
            if (!goToFireCraftMI) goToFireCraftMI = FindMethodInHierarchy(navManagerKlass, "GoToFireCraft", 1);
            if (goToFireCraftMI) {
                void* emptyStr = IL2CPP::il2cpp_string_new("");
                void* params[1] = { emptyStr };
                SafeInvoke(goToFireCraftMI, navInstance, params);
                Vector3 navTarget = *(Vector3*)((uint8_t*)navInstance + 0x20);
                if (fabsf(navTarget.x) > 0.01f || fabsf(navTarget.y) > 0.01f) {
                    cachedNavTarget = navTarget;
                    hasCachedNavTarget = true;
                }
            }
        }
    }

    if (hasCachedNavTarget) {
        float dx = cachedNavTarget.x - playerPos.x;
        float dy = cachedNavTarget.y - playerPos.y;
        float dist = sqrtf(dx * dx + dy * dy);
        if (dist < 10000.0f) {
            *outClosestFire = cachedNavTarget;
            if (outDist) *outDist = dist;
            return true;
        }
    }

    return false;
}

static void LoadTweakPreferences() {
    static bool s_loaded = false;
    if (s_loaded) return;
    s_loaded = true;

    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    if ([defs objectForKey:@"THTweak_AutoSellKey"]) {
        g_autoSellKey = [defs boolForKey:@"THTweak_AutoSellKey"];
    }
    if ([defs objectForKey:@"THTweak_RecipeMerge"]) {
        g_recipeMergeEnabled = [defs boolForKey:@"THTweak_RecipeMerge"];
    }
    if ([defs objectForKey:@"THTweak_RecipeMergeGoToFire"]) {
        g_recipeMergeGoToFire = [defs boolForKey:@"THTweak_RecipeMergeGoToFire"];
    }
    NSString *savedRec = [defs stringForKey:@"THTweak_RecipeBase64"];
    if (savedRec && [savedRec length] > 0) {
        g_recipeBase64 = [savedRec copy];
        NSString *clean = [g_recipeBase64 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        clean = [clean stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        clean = [clean stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        clean = [clean stringByReplacingOccurrencesOfString:@" " withString:@""];
        while ([clean length] % 4 != 0) clean = [clean stringByAppendingString:@"="];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:clean options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (data) {
            ParseRecipeData(data, g_currentRecipe);
        }
    }
}

// Farm Mob Filter
static bool      g_mobFilterEnabled          = false;
static int32_t   g_selectedMobCategory       = 0; // 0: Tất cả, 1-8: Presets, 100+ID: Exact, 999: Custom
static NSString* g_customMobFilterIds        = @"";
static NSString* g_customMobFilterName       = @"";

// Avoid Mob Filter
static bool      g_avoidMobFilterEnabled     = false;
static int32_t   g_selectedAvoidMobCategory  = 0; // 0: Tất cả quái, 1-8: Presets, 100+ID: Exact, 999: Custom
static NSString* g_customAvoidMobFilterIds   = @"";
static NSString* g_customAvoidMobFilterName  = @"";

// PVP & Player Protection
static bool      g_avoidPlayers              = false;
static float     g_avoidPlayerRange          = 8.0f;
static bool      g_autoQuitNearPlayer        = false;
static float     g_autoQuitPlayerRange       = 12.0f;

// Range Circles (Radar HUD)
static bool      g_showRangeCircles          = true;

static void* g_cachedPlayerMovement = nullptr;
static void* g_cachedJoystick       = nullptr;
static void* g_cachedMainCam        = nullptr;
static double g_lastCamFetchTime    = 0;

// Cached data updated by TickCheats (0.3s)
static Vector3 g_cachedPlayerPos     = {0,0,0};
static Vector3 g_cachedTargetPos     = {0,0,0};
static bool    g_hasCachedTarget     = false;
static bool    g_cachedTargetIsMob   = false;
static float   g_cachedClosestDist   = 999999.0f;
static void*   g_cachedMobObj        = nullptr;
static bool    s_hasAvoidForces      = false;
static float   s_avoidX = 0.0f, s_avoidY = 0.0f;

// Hysteresis variables for movement
static Vector3 g_lastTargetPos       = {0,0,0};
static bool    g_isAtTarget          = false;
static void*   g_currentTargetObj    = nullptr; // sticky target for dig
static double  g_targetStartTime     = 0.0;

static void*  g_lastFailedTile      = nullptr;


static void* GetLocalPlayerMovement();
static bool IsValidUnityObj(void* obj);
static void* GetClientManagerInstance();
static bool WorldToScreen(Vector3 worldPos, CGPoint *outScreenPt);
static CGFloat GetScreenRadius(Vector3 centerWorldPos, float worldRadius);

// Mob Entry Structure for Filter Options
struct MobFilterEntry {
    int32_t filterId;
    const char* displayName;
    const char* shortName;
};

static const MobFilterEntry kMobCategoryOptions[] = {
    { 0, "🌐 Tất cả quái", "Tất cả" },
    { 1, "🦖 Nhóm T-Rex / Khủng Long (ID 13, 21, 60-64, 66)", "T-Rex/K.Long" },
    { 2, "🐉 Nhóm Rồng Đỏ / Xanh (ID 5, 9)", "Rồng Đỏ/Xanh" },
    { 3, "🧌 Nhóm Orc (ID 8, 14, 15, 16, 24, 25)", "Orc" },
    { 4, "👑 Nhóm Boss / Warden (ID 30, 39, 42, 43, 53, 58, 65)", "Boss/Warden" },
    { 5, "🐺 Nhóm Thú / Sói / Gấu (ID 4, 6, 28, 29, 37, 38)", "Thú/Sói/Gấu" },
    { 6, "🐢 Nhóm Rùa / Ốc Sên (ID 1, 2)", "Rùa/Ốc" },
    { 7, "🦇 Nhóm Ma / Dơi / Rắn (ID 18, 19, 44, 57)", "Ma/Dơi/Rắn" },
    { 8, "⚔️ Nhóm Viking (ID 33-36, 45-51)", "Viking" },
    
    // Exact Individual Mobs
    { 101, "🐢 ID 1: Rùa (Turtle)", "ID 1 (Rùa)" },
    { 102, "🐌 ID 2: Ốc Sên (Snailu)", "ID 2 (Ốc)" },
    { 104, "🦟 ID 4: Muỗi (Mosqui)", "ID 4 (Muỗi)" },
    { 105, "🐉 ID 5: Rồng Đỏ (RedDragon)", "ID 5 (Rồng Đỏ)" },
    { 106, "🕷️ ID 6: Chúa Nhện (SpiderOverlord)", "ID 6 (Chúa Nhện)" },
    { 108, "🧌 ID 8: Orc Đại Tướng (OrcWarlord)", "ID 8 (Orc Warlord)" },
    { 109, "🐲 ID 9: Rồng Xanh (BlueDragon)", "ID 9 (Rồng Xanh)" },
    { 113, "🦖 ID 13: T-Rex Đỏ (RedTRex)", "ID 13 (T-Rex Đỏ)" },
    { 114, "🧌 ID 14: Orc Thường (Orc)", "ID 14 (Orc Thường)" },
    { 115, "🧌 ID 15: Thủ Lĩnh Orc (OrcLeader)", "ID 15 (Thủ Lĩnh Orc)" },
    { 116, "👑 ID 16: Vua Orc (OrcKing)", "ID 16 (Vua Orc)" },
    { 118, "🐍 ID 18: Rắn Trườn (Slither)", "ID 18 (Rắn Trườn)" },
    { 119, "👻 ID 19: Bóng Ma (Spectre)", "ID 19 (Bóng Ma)" },
    { 121, "💀 ID 21: T-Rex Bất Tử (UndeadTRex)", "ID 21 (Undead T-Rex)" },
    { 124, "🪓 ID 24: Orc Cầm Rìu (AxeOrc)", "ID 24 (Axe Orc)" },
    { 126, "🐮 ID 26: Bò Tuyết (SnowCow)", "ID 26 (Bò Tuyết)" },
    { 127, "🦣 ID 27: Voi Ma Mút (SnowMammoth)", "ID 27 (Voi Ma Mút)" },
    { 128, "🐺 ID 28: Sói Trắng (WhiteWolf)", "ID 28 (Sói Trắng)" },
    { 129, "🐻 ID 29: Gấu Tuyết (SnowBear)", "ID 29 (Gấu Tuyết)" },
    { 130, "🐺 ID 30: Người Sói (Werewolf)", "ID 30 (Người Sói)" },
    { 133, "⚔️ ID 33: Thủ Lĩnh Viking (VikingLeader)", "ID 33 (Viking Leader)" },
    { 134, "🛡️ ID 34: Chiến Binh Viking (VikingWarrior)", "ID 34 (Viking Warrior)" },
    { 136, "👑 ID 36: Vua Viking (VikingKing)", "ID 36 (Viking King)" },
    { 143, "🧛 ID 43: Dracula", "ID 43 (Dracula)" },
    { 144, "🦇 ID 44: Dơi Quỷ (Bat)", "ID 44 (Dơi Quỷ)" },
    { 157, "🐍 ID 57: Rắn Độc (Snake)", "ID 57 (Rắn Độc)" },
    { 160, "🦎 ID 60: Aquasaur (Thằn Lằn Nước)", "ID 60 (Aquasaur)" },
    { 161, "🦕 ID 61: Brachiosaurus (Khủng Long Cổ Dài)", "ID 61 (Brachio)" },
    { 162, "🐊 ID 62: Crocodylosaurus (Khủng Long Cá Sấu)", "ID 62 (Crocodylo)" },
    { 163, "🦅 ID 63: Pterosaur (Thằn Lằn Bay)", "ID 63 (Pterosaur)" },
    { 164, "🦖 ID 64: Tyrannosaurus (Bạo Chúa)", "ID 64 (Tyrannosaur)" },
    { 165, "👑 ID 65: Vua Slime Độc (PoisonSlimeKing)", "ID 65 (Slime King)" },
    
    // Custom option
    { 999, "✍️ Nhập ID & Tên tùy chỉnh...", "Tùy chỉnh" }
};
static const int kMobCategoryOptionCount = sizeof(kMobCategoryOptions) / sizeof(kMobCategoryOptions[0]);

static NSString* GetMobFilterShortName(int32_t filterId, NSString* customIds, NSString* customName) {
    if (filterId == 999) {
        if (customIds && [customIds length] > 0) return [NSString stringWithFormat:@"ID: %@", customIds];
        if (customName && [customName length] > 0) return [NSString stringWithFormat:@"Tên: %@", customName];
        return @"Tùy chỉnh";
    }
    for (int i = 0; i < kMobCategoryOptionCount; i++) {
        if (kMobCategoryOptions[i].filterId == filterId) {
            return [NSString stringWithUTF8String:kMobCategoryOptions[i].shortName];
        }
    }
    return @"Tất cả";
}

static void* FindMethodWithPrefix(void* klass, const char* prefix) {
    if (!klass || !IL2CPP::il2cpp_class_get_methods || !IL2CPP::il2cpp_method_get_name) return nullptr;
    void* iter = nullptr;
    void* method = nullptr;
    while ((method = IL2CPP::il2cpp_class_get_methods(klass, &iter))) {
        const char* name = IL2CPP::il2cpp_method_get_name(method);
        if (name && strncmp(name, prefix, strlen(prefix)) == 0) {
            return method;
        }
    }
    if (IL2CPP::il2cpp_class_get_parent) {
        void* parent = IL2CPP::il2cpp_class_get_parent(klass);
        while (parent) {
            iter = nullptr;
            while ((method = IL2CPP::il2cpp_class_get_methods(parent, &iter))) {
                const char* name = IL2CPP::il2cpp_method_get_name(method);
                if (name && strncmp(name, prefix, strlen(prefix)) == 0) {
                    return method;
                }
            }
            parent = IL2CPP::il2cpp_class_get_parent(parent);
        }
    }
    return nullptr;
}

static void HookIl2CppMethod(void* mi, void* newFunc, void** origFunc) {
    if (!mi || !newFunc) return;
    if (origFunc) {
        *origFunc = *(void**)mi;
    }
    *(void**)mi = newFunc;
}

static void (*orig_HUDView_RequestAd)(void* hudViewInst, void* method) = nullptr;
static void new_HUDView_RequestAd(void* hudViewInst, void* method) {
    if (g_autoWatchAds) {
        NSLog(@"[THTweak] HUDView.RequestAd called, auto watching ads...");
        static void* onClickOkWatchAdMI = nullptr;
        static void* hudViewKlass = nullptr;
        if (!hudViewKlass) hudViewKlass = IL2CPP::il2cpp_object_get_class(hudViewInst);
        if (hudViewKlass && !onClickOkWatchAdMI) {
            onClickOkWatchAdMI = FindMethodWithPrefix(hudViewKlass, "<RequestAd>g__OnClickOkWatchAd|");
        }
        if (onClickOkWatchAdMI) {
            SafeInvoke(onClickOkWatchAdMI, hudViewInst, nullptr);
            return;
        }
    }
    if (orig_HUDView_RequestAd) {
        orig_HUDView_RequestAd(hudViewInst, method);
    }
}

static void EnsureAdHooks() {
    if (!s_attached) return;
    
    static bool hudViewHooked = false;
    if (!hudViewHooked) {
        void* hudViewKlass = ScanFindClass("", "HUDView");
        if (hudViewKlass) {
            void* requestAd_mi = FindMethodInHierarchy(hudViewKlass, "RequestAd", 0);
            if (requestAd_mi) {
                HookIl2CppMethod(requestAd_mi, (void*)&new_HUDView_RequestAd, (void**)&orig_HUDView_RequestAd);
                hudViewHooked = true;
                NSLog(@"[THTweak] Hooked HUDView.RequestAd successfully via EnsureAdHooks");
            }
        }
    }
}

// Boss identification heuristic
static bool IsBossMob(void* mob, void* playerObj) {
    if (!mob) return false;
    void* mobHealth = *(void**)((uint8_t*)mob + 0x1d0);
    if (mobHealth) {
        int32_t maxHp = *(int32_t*)((uint8_t*)mobHealth + 0x6c);
        if (maxHp >= 10000) return true;
        if (playerObj) {
            void* playerHealth = *(void**)((uint8_t*)playerObj + 0x1d0);
            if (playerHealth) {
                int32_t playerMaxHp = *(int32_t*)((uint8_t*)playerHealth + 0x6c);
                if (playerMaxHp > 0 && maxHp >= playerMaxHp * 3 && maxHp >= 3000) return true;
            }
        }
    }
    void* nameStrObj = *(void**)((uint8_t*)mob + 0x70);
    if (!nameStrObj) nameStrObj = *(void**)((uint8_t*)mob + 0x78);
    if (nameStrObj) {
        int32_t len = *(int32_t*)((uint8_t*)nameStrObj + 0x10);
        wchar_t* chars = (wchar_t*)((uint8_t*)nameStrObj + 0x14);
        if (len > 0 && chars) {
            if (WideStringContains(chars,len,L"boss") || WideStringContains(chars,len,L"king") ||
                WideStringContains(chars,len,L"vua")  || WideStringContains(chars,len,L"giant"))
                return true;
        }
    }
    return false;
}

static bool IsMobMatchingFilter(void* mob, bool filterEnabled, int32_t filterIndex, NSString* customIds, NSString* customName) {
    if (!filterEnabled) return true;
    if (!mob) return false;
    if (filterIndex == 0) return true; // Tất cả
    
    int32_t mobId = *(int32_t*)((uint8_t*)mob + 0x268);
    void* nameStrObj = *(void**)((uint8_t*)mob + 0x70);
    if (!nameStrObj) nameStrObj = *(void**)((uint8_t*)mob + 0x78);
    wchar_t* chars = nullptr;
    int32_t len = 0;
    if (nameStrObj) {
        len = *(int32_t*)((uint8_t*)nameStrObj + 0x10);
        chars = (wchar_t*)((uint8_t*)nameStrObj + 0x14);
    }
    
    if (filterIndex == 999) {
        if (customIds && [customIds length] > 0) {
            NSArray *parts = [customIds componentsSeparatedByString:@","];
            for (NSString *p in parts) {
                NSString *trimmed = [p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([trimmed length] > 0 && [trimmed intValue] == mobId) {
                    return true;
                }
            }
        }
        if (customName && [customName length] > 0 && chars && len > 0) {
            unichar targetW[64];
            int kwLen = (int)[customName length];
            if (kwLen > 60) kwLen = 60;
            [customName getCharacters:targetW range:NSMakeRange(0, kwLen)];
            if (WideStringContains(chars, len, (const wchar_t*)targetW)) return true;
        }
        return false;
    }
    
    if (filterIndex >= 100 && filterIndex < 900) {
        int exactId = filterIndex - 100;
        if (mobId == exactId) return true;
        return false;
    }
    
    switch (filterIndex) {
        case 1: // T-Rex / Khủng Long
            if (mobId == 13 || mobId == 21 || (mobId >= 60 && mobId <= 64) || mobId == 66) return true;
            if (chars && (WideStringContains(chars, len, L"trex") || WideStringContains(chars, len, L"saur") || WideStringContains(chars, len, L"dino") || WideStringContains(chars, len, L"khung long"))) return true;
            break;
        case 2: // Rồng Đỏ / Xanh
            if (mobId == 5 || mobId == 9) return true;
            if (chars && (WideStringContains(chars, len, L"dragon") || WideStringContains(chars, len, L"rong"))) return true;
            break;
        case 3: // Orc
            if (mobId == 8 || mobId == 14 || mobId == 15 || mobId == 16 || mobId == 24 || mobId == 25) return true;
            if (chars && WideStringContains(chars, len, L"orc")) return true;
            break;
        case 4: // Boss / Warden
            if (mobId == 30 || mobId == 39 || mobId == 40 || mobId == 42 || mobId == 43 || mobId == 53 || mobId == 55 || mobId == 58 || mobId == 65) return true;
            if (chars && (WideStringContains(chars, len, L"boss") || WideStringContains(chars, len, L"warden") || WideStringContains(chars, len, L"dracula") || WideStringContains(chars, len, L"werewolf") || WideStringContains(chars, len, L"slime"))) return true;
            break;
        case 5: // Thú (Sói, Gấu, Nhện, Muỗi)
            if (mobId == 4 || mobId == 6 || mobId == 28 || mobId == 29 || mobId == 37 || mobId == 38) return true;
            if (chars && (WideStringContains(chars, len, L"wolf") || WideStringContains(chars, len, L"bear") || WideStringContains(chars, len, L"spider") || WideStringContains(chars, len, L"mosqui") || WideStringContains(chars, len, L"soi") || WideStringContains(chars, len, L"gau"))) return true;
            break;
        case 6: // Rùa / Ốc Sên
            if (mobId == 1 || mobId == 2) return true;
            if (chars && (WideStringContains(chars, len, L"turtle") || WideStringContains(chars, len, L"rua") || WideStringContains(chars, len, L"snail") || WideStringContains(chars, len, L"sen"))) return true;
            break;
        case 7: // Ma / Dơi / Rắn
            if (mobId == 18 || mobId == 19 || mobId == 44 || mobId == 57) return true;
            if (chars && (WideStringContains(chars, len, L"spectre") || WideStringContains(chars, len, L"bat") || WideStringContains(chars, len, L"snake") || WideStringContains(chars, len, L"slither") || WideStringContains(chars, len, L"ran") || WideStringContains(chars, len, L"doi"))) return true;
            break;
        case 8: // Viking
            if ((mobId >= 33 && mobId <= 36) || (mobId >= 45 && mobId <= 51)) return true;
            if (chars && WideStringContains(chars, len, L"viking")) return true;
            break;
    }
    return false;
}

static void* GetClientManagerInstance() {
    static void* clientManagerKlass = nullptr;
    if (!clientManagerKlass) clientManagerKlass = ScanFindClass("", "ClientManager");
    if (!clientManagerKlass) return nullptr;
    static void* cmInstanceField = nullptr;
    if (!cmInstanceField) cmInstanceField = IL2CPP::il2cpp_class_get_field_from_name(clientManagerKlass, "instance");
    if (!cmInstanceField || !IL2CPP::il2cpp_field_static_get_value) return nullptr;
    void* cm = nullptr;
    IL2CPP::il2cpp_field_static_get_value(cmInstanceField, &cm);
    if (cm && IsValidUnityObj(cm)) return cm;
    return nullptr;
}

static bool WorldToScreen(Vector3 worldPos, CGPoint *outScreenPt) {
    if (!outScreenPt) return false;
    void* cm = GetClientManagerInstance();
    if (!cm) return false;
    void* characterCam = *(void**)((uint8_t*)cm + 0x38); // cameraFollow
    if (!characterCam || !IsValidUnityObj(characterCam)) return false;
    void* cameraObj = *(void**)((uint8_t*)characterCam + 0x40); // cam
    if (!cameraObj || !IsValidUnityObj(cameraObj)) return false;
    
    static void* w2sMI = nullptr;
    static void* cameraKlass = nullptr;
    if (!cameraKlass) cameraKlass = ScanFindClass("UnityEngine", "Camera");
    if (cameraKlass && !w2sMI) {
        w2sMI = FindMethodInHierarchy(cameraKlass, "WorldToScreenPoint", 1);
    }
    if (!w2sMI) return false;
    
    void* params[1] = { &worldPos };
    void* boxed = SafeInvoke(w2sMI, cameraObj, params);
    if (!boxed) return false;
    
    Vector3 screenV = *(Vector3*)((uint8_t*)boxed + 16);
    if (screenV.z < 0.0f) return false; // Behind camera
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    // Unity: Y=0 at bottom -> UIKit: Y=0 at top
    outScreenPt->x = screenV.x / screenScale;
    outScreenPt->y = bounds.size.height - (screenV.y / screenScale);
    return true;
}

static CGFloat GetScreenRadius(Vector3 centerWorldPos, float worldRadius) {
    CGPoint centerPt = CGPointZero;
    if (!WorldToScreen(centerWorldPos, &centerPt)) return 0.0f;
    
    Vector3 edgeWorldPos = { centerWorldPos.x + worldRadius, centerWorldPos.y, centerWorldPos.z };
    CGPoint edgePt = CGPointZero;
    if (!WorldToScreen(edgeWorldPos, &edgePt)) return 0.0f;
    
    CGFloat dx = edgePt.x - centerPt.x;
    CGFloat dy = edgePt.y - centerPt.y;
    return sqrtf(dx * dx + dy * dy);
}

static void UseHpPotion(void* playerObj) {
    if (!playerObj) return;
    bool potionUsed = false;
    
    // Method 1: Try via HUDView potionShortcut (offset 0x388 in latest dump, dynamically resolved)
    static void* hudViewKlass = nullptr;
    if (!hudViewKlass) hudViewKlass = ScanFindClass("", "HUDView");
    if (hudViewKlass) {
        static size_t s_off_potionShortcut = 0;
        if (s_off_potionShortcut == 0 && IL2CPP::il2cpp_class_get_field_from_name && IL2CPP::il2cpp_field_get_offset) {
            void* field = IL2CPP::il2cpp_class_get_field_from_name(hudViewKlass, "potionShortcut");
            if (field) s_off_potionShortcut = IL2CPP::il2cpp_field_get_offset(field);
        }
        if (s_off_potionShortcut == 0) s_off_potionShortcut = 0x388;

        int32_t count = 0;
        void* arr = Il2cppFindObjects(hudViewKlass, &count);
        if (arr && count > 0) {
            void* hudViewInst = GetArrElem(arr, 0);
            if (hudViewInst && IsValidUnityObj(hudViewInst)) {
                void* potionShortcut = *(void**)((uint8_t*)hudViewInst + s_off_potionShortcut);
                if (potionShortcut && IsValidUnityObj(potionShortcut)) {
                    void* equipment = *(void**)((uint8_t*)potionShortcut + 0x78);
                    if (equipment) {
                        static void* onRequestUsePotionMI = nullptr;
                        if (!onRequestUsePotionMI)
                            onRequestUsePotionMI = FindMethodInHierarchy(hudViewKlass, "OnRequestUsePotion", 1);
                        if (onRequestUsePotionMI) {
                            void* params[1] = { equipment };
                            SafeInvoke(onRequestUsePotionMI, hudViewInst, params);
                            potionUsed = true;
                        }
                    }
                }
            }
        }
    }
    
    // Method 2: Fallback - Search inventory for Potion item (itemId 32, or Item/BuffItem)
    if (!potionUsed) {
        void* invObj = *(void**)((uint8_t*)playerObj + 0x318); // characterInventory
        if (invObj) {
            void* invList = *(void**)((uint8_t*)invObj + 0x80); // localEquipments
            if (invList) {
                void* invArr = *(void**)((uint8_t*)invList + 0x10);
                int32_t invSize = *(int32_t*)((uint8_t*)invList + 0x18);
                if (invArr && invSize > 0 && invSize < 500) {
                    for (int i = 0; i < invSize; i++) {
                        void* item = *((void**)((uint8_t*)invArr + 0x20) + i);
                        if (!item) continue;
                        int32_t itemId = *(int32_t*)((uint8_t*)item + 0x18); // itemId
                        int32_t eqType = *(int32_t*)((uint8_t*)item + 0x2c); // equipmentType
                        if (itemId == 32 || eqType == 10 || eqType == 22) { // Potion ID or Item or BuffItem
                            void* idStringObj = *(void**)((uint8_t*)item + 0x10);
                            if (idStringObj) {
                                static void* requestUseItemMI = nullptr;
                                static void* pbKlass = nullptr;
                                if (!pbKlass) pbKlass = ScanFindClass("", "PlayerBehavior");
                                if (pbKlass && !requestUseItemMI)
                                    requestUseItemMI = FindMethodInHierarchy(pbKlass, "RequestUseItem", 3);
                                if (requestUseItemMI) {
                                    int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                                    void* passStr = IL2CPP::il2cpp_string_new ? IL2CPP::il2cpp_string_new("") : nullptr;
                                    void* params[3] = { idStringObj, &apiToken, passStr };
                                    SafeInvoke(requestUseItemMI, playerObj, params);
                                    potionUsed = true;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

static void* GetLocalPlayerMovement() {
    if (g_cachedPlayerMovement) {
        if (IsValidUnityObj(g_cachedPlayerMovement)) {
            return g_cachedPlayerMovement;
        } else {
            g_cachedPlayerMovement = nullptr;
        }
    }
    static void* playerMovementKlass = nullptr;
    if (!playerMovementKlass) playerMovementKlass = ScanFindClass("", "AuthorativePlayerMovement");
    if (!playerMovementKlass) return nullptr;
    int32_t count = 0;
    void* arr = Il2cppFindObjects(playerMovementKlass, &count);
    if (!arr || count == 0) return nullptr;
    static void* get_isLocalPlayerMI = nullptr;
    if (!get_isLocalPlayerMI) {
        void* networkBehaviourKlass = ScanFindClass("Mirror", "NetworkBehaviour");
        if (networkBehaviourKlass)
            get_isLocalPlayerMI = FindMethodInHierarchy(networkBehaviourKlass, "get_isLocalPlayer", 0);
    }
    for (int i = 0; i < count; i++) {
        void* o = GetArrElem(arr, i);
        if (!o || !IsValidUnityObj(o)) continue;
        if (get_isLocalPlayerMI) {
            void* isLocalObj = SafeInvoke(get_isLocalPlayerMI, o, nullptr);
            if (isLocalObj && *(bool*)((uint8_t*)isLocalObj + 16)) {
                g_cachedPlayerMovement = o;
                return o;
            }
        }
    }
    return nullptr;
}

static void* GetJoystickObject() {
    if (g_cachedJoystick) {
        if (IsValidUnityObj(g_cachedJoystick)) {
            return g_cachedJoystick;
        } else {
            g_cachedJoystick = nullptr;
        }
    }
    static void* joystickKlass = nullptr;
    if (!joystickKlass) joystickKlass = ScanFindClass("", "Joystick");
    if (!joystickKlass) return nullptr;
    int32_t count = 0;
    void* arr = Il2cppFindObjects(joystickKlass, &count);
    if (!arr || count == 0) return nullptr;
    for (int i = 0; i < count; i++) {
        void* o = GetArrElem(arr, i);
        if (o && IsValidUnityObj(o)) {
            g_cachedJoystick = o;
            return o;
        }
    }
    return nullptr;
}

// Helper: cleanly zero auto external movement inputs and UI joystick
static void HardStopJoystick(void* playerMovement, Vector3 playerPos) {
    if (playerMovement) {
        static void* setExternalInputMI = nullptr;
        static void* stopInputMI = nullptr;
        static void* pmKlass = nullptr;
        if (!pmKlass) pmKlass = ScanFindClass("", "AuthorativePlayerMovement");
        if (pmKlass) {
            if (!setExternalInputMI) setExternalInputMI = FindMethodInHierarchy(pmKlass, "SetExternalInput", 1);
            if (!stopInputMI) stopInputMI = FindMethodInHierarchy(pmKlass, "StopInput", 0);
        }

        if (setExternalInputMI) {
            Vector2 zero = { 0.0f, 0.0f };
            void* params[1] = { &zero };
            SafeInvoke(setExternalInputMI, playerMovement, params);
        }
        if (stopInputMI) {
            SafeInvoke(stopInputMI, playerMovement, nullptr);
        }
    }
    void* joy = GetJoystickObject();
    if (joy) {
        static void* setJoystickValuesMI = nullptr;
        static void* joystickKlass = nullptr;
        if (!joystickKlass) joystickKlass = ScanFindClass("", "Joystick");
        if (joystickKlass && !setJoystickValuesMI)
            setJoystickValuesMI = FindMethodInHierarchy(joystickKlass, "SetJoystickValues", 1);
        if (setJoystickValuesMI) {
            Vector2 zero = {0.0f, 0.0f};
            void* params[1] = { &zero };
            SafeInvoke(setJoystickValuesMI, joy, params);
        } else {
            *(Vector2*)((uint8_t*)joy + 0x58) = {0.0f, 0.0f};
        }
    }
}

static void ScanEquipmentList(void* listObj, int32_t eqType, int32_t rareType, int32_t level, bool &shouldEquip) {
    if (!listObj) return;
    void* arr = *(void**)((uint8_t*)listObj + 0x10);
    int32_t size = *(int32_t*)((uint8_t*)listObj + 0x18);
    if (arr && size > 0) {
        for (int j = 0; j < size; j++) {
            void* eqItem = *((void**)((uint8_t*)arr + 0x20) + j);
            if (!eqItem) continue;
            int32_t eqItemType = *(int32_t*)((uint8_t*)eqItem + 0x2c); // equipmentType
            if (eqItemType == eqType) {
                int32_t er = *(int32_t*)((uint8_t*)eqItem + 0x28); // rareType
                int32_t el = *(int32_t*)((uint8_t*)eqItem + 0x1c); // level
                if (er > rareType || (er == rareType && el >= level)) {
                    shouldEquip = false;
                    break;
                }
            }
        }
    }
}

// =============================================
// TickCheats – runs every 0.3s
// =============================================
static void TickCheats() {
    if (g_window) [g_window attachWindowSceneIfNeeded];
    if (!s_attached) return;
    EnsureAdHooks();

    static int s_cacheResetTicks = 0;
    if (++s_cacheResetTicks > 10) {
        s_cacheResetTicks = 0;
        g_cachedPlayerMovement = nullptr;
        g_cachedJoystick = nullptr;
    }

    if (!g_menuMasterSwitch) {
        g_hasCachedTarget = false;
        g_currentTargetObj = nullptr;
        g_isAtTarget = false;
        return;
    }

    void* playerMovement = GetLocalPlayerMovement();
    if (!playerMovement || !IsValidUnityObj(playerMovement)) { g_hasCachedTarget = false; return; }
    void* playerObj = *(void**)((uint8_t*)playerMovement + 0xa8);
    if (!playerObj || !IsValidUnityObj(playerObj)) { g_hasCachedTarget = false; return; }

    // ClientManager instance
    static void* clientManagerKlass = nullptr;
    if (!clientManagerKlass) clientManagerKlass = ScanFindClass("", "ClientManager");
    static void* cmInstanceField = nullptr;
    if (clientManagerKlass && !cmInstanceField)
        cmInstanceField = IL2CPP::il2cpp_class_get_field_from_name(clientManagerKlass, "instance");
    if (cmInstanceField) {
        void* cm = nullptr;
        IL2CPP::il2cpp_field_static_get_value(cmInstanceField, &cm);
        if (cm && IsValidUnityObj(cm)) {

            // Auto watch ads
            if (g_autoWatchAds) {
                static void* hudViewKlass = nullptr;
                if (!hudViewKlass) hudViewKlass = ScanFindClass("", "HUDView");
                if (hudViewKlass) {
                    int32_t hudCount = 0;
                    void* hudArr = Il2cppFindObjects(hudViewKlass, &hudCount);
                    if (hudArr && hudCount > 0) {
                        void* hudViewInst = GetArrElem(hudArr, 0);
                        if (hudViewInst && IsValidUnityObj(hudViewInst)) {
                            static void* isActiveAdUiMI = nullptr;
                            if (!isActiveAdUiMI) {
                                isActiveAdUiMI = FindMethodInHierarchy(hudViewKlass, "IsActiveAdUi", 0);
                            }
                            if (isActiveAdUiMI) {
                                bool isActive = false;
                                void* exc = nullptr;
                                void* res = IL2CPP::il2cpp_runtime_invoke(isActiveAdUiMI, hudViewInst, nullptr, &exc);
                                if (res) {
                                    isActive = *(bool*)((uint8_t*)res + 0x10);
                                }
                                
                                if (isActive) {
                                    bool isWatching = *(bool*)((uint8_t*)playerObj + 0x2c8);
                                    double now = CACurrentMediaTime();
                                    if (!isWatching && (now - s_lastAutoAdTime > 5.0)) {
                                        s_lastAutoAdTime = now;
                                        NSLog(@"[THTweak] Auto watch ads detected active ad UI. Requesting ad...");
                                        static void* requestAdMI = nullptr;
                                        if (!requestAdMI) requestAdMI = FindMethodInHierarchy(hudViewKlass, "RequestAd", 0);
                                        if (requestAdMI) {
                                            SafeInvoke(requestAdMI, hudViewInst, nullptr);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Camera Zoom
            if (g_cameraZoomOn) {
                void* characterCam = *(void**)((uint8_t*)cm + 0x38);
                if (characterCam && IsValidUnityObj(characterCam)) {
                    void* cameraObj = *(void**)((uint8_t*)characterCam + 0x40);
                    if (cameraObj && IsValidUnityObj(cameraObj)) {
                        static void* set_orthoMI = nullptr;
                        static void* cameraKlass = nullptr;
                        if (!cameraKlass) cameraKlass = ScanFindClass("UnityEngine", "Camera");
                        if (cameraKlass && !set_orthoMI)
                            set_orthoMI = FindMethodInHierarchy(cameraKlass, "set_orthographicSize", 1);
                        if (set_orthoMI) {
                            float size = g_cameraZoomValue;
                            void* params[1] = { &size };
                            SafeInvoke(set_orthoMI, cameraObj, params);
                        }
                    }
                }
            }
        }
    }

    // Read player position
    static void* getTransformMI = nullptr, *getPositionMI = nullptr;
    static void* componentKlass = nullptr, *transformKlass = nullptr;
    if (!componentKlass) componentKlass = ScanFindClass("UnityEngine", "Component");
    if (componentKlass && !getTransformMI) getTransformMI = FindMethodInHierarchy(componentKlass, "get_transform", 0);
    if (!transformKlass) transformKlass = ScanFindClass("UnityEngine", "Transform");
    if (transformKlass && !getPositionMI) getPositionMI = FindMethodInHierarchy(transformKlass, "get_position", 0);
    if (!getTransformMI || !getPositionMI) return;

    void* playerTrans = SafeInvoke(getTransformMI, playerObj, nullptr);
    Vector3 playerPos = {0,0,0};
    if (playerTrans) {
        void* boxed = SafeInvoke(getPositionMI, playerTrans, nullptr);
        if (boxed) playerPos = *(Vector3*)((uint8_t*)boxed + 16);
    }
    g_cachedPlayerPos = playerPos;

    // Health and death tracking
    void* healthObj = *(void**)((uint8_t*)playerObj + 0x1d0);
    if (healthObj) {
        int32_t currentHp = *(int32_t*)((uint8_t*)healthObj + 0x68);
        int32_t maxHp = *(int32_t*)((uint8_t*)healthObj + 0x6c);
        
        // Death / Revive tracking
        if (currentHp <= 0) {
            if (!g_wasDead) {
                g_wasDead = true;
                g_deathPos = playerPos;
                g_hasDeathPos = true;
                g_hasFarmPosBeforeFire = false;
                g_isReturningToFarm = false;
                g_isGoingToFire = false;
                g_isAtFireForRecipe = false;
            }
        } else {
            if (g_wasDead) {
                g_wasDead = false;
                if (g_returnToDeathPos) {
                    g_hasDeathPos = true;
                }
            }
        }

        // Auto HP Potion (Fix: Prevent drinking potion when HP is full or stats uninitialized)
        if (g_autoHp && healthObj && IsValidUnityObj(healthObj)) {
            if (currentHp > 0 && maxHp > 0) {
                bool isFull = (currentHp >= maxHp);
                if (!isFull) {
                    float hpRatio = (float)currentHp / (float)maxHp;
                    if (hpRatio > 0.01f && hpRatio < 0.99f && hpRatio <= g_autoHpPercent) {
                        static double lastPotionTime = 0;
                        double nowHpTime = [[NSProcessInfo processInfo] systemUptime];
                        if (nowHpTime - lastPotionTime >= 1.5) {
                            lastPotionTime = nowHpTime;
                            UseHpPotion(playerObj);
                        }
                    }
                }
            }
        }
    }

    // Auto Revive
    if (g_autoRevive) {
        void* healthObj = *(void**)((uint8_t*)playerObj + 0x1d0);
        if (healthObj && *(int32_t*)((uint8_t*)healthObj + 0x68) <= 0) {
            static double lastReviveTime = 0;
            double now = [[NSProcessInfo processInfo] systemUptime];
            if (now - lastReviveTime >= 3.0) {
                lastReviveTime = now;
                static void* requestReviveMI = nullptr;
                static void* playerBehaviorKlass = nullptr;
                if (!playerBehaviorKlass) playerBehaviorKlass = ScanFindClass("", "PlayerBehavior");
                if (playerBehaviorKlass && !requestReviveMI)
                    requestReviveMI = FindMethodInHierarchy(playerBehaviorKlass, "RequestRevive", 2);
                if (requestReviveMI) {
                    int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                    bool f = false; void* p[2] = { &f, &apiToken };
                    SafeInvoke(requestReviveMI, playerObj, p);
                    bool t = true; p[0] = &t;
                    SafeInvoke(requestReviveMI, playerObj, p);
                }
            }
        }
    }

    // Auto Equip
    if (g_autoEquip) {
        static double lastEquipTime = 0;
        double now = [[NSProcessInfo processInfo] systemUptime];
        if (now - lastEquipTime >= 1.5) {
            lastEquipTime = now;
            void* invObj = *(void**)((uint8_t*)playerObj + 0x318); // characterInventory
            void* eqObj  = *(void**)((uint8_t*)playerObj + 0x310); // characterEquipments
            if (invObj && eqObj) {
                void* invList = *(void**)((uint8_t*)invObj + 0x80); // localEquipments
                if (invList) {
                    void* invArr = *(void**)((uint8_t*)invList + 0x10);
                    int32_t invSize = *(int32_t*)((uint8_t*)invList + 0x18);
                    if (invArr && invSize > 0) {
                        for (int i = 0; i < invSize; i++) {
                            void* item = *((void**)((uint8_t*)invArr + 0x20) + i);
                            if (!item) continue;
                            int32_t rareType = *(int32_t*)((uint8_t*)item + 0x28);
                            int32_t eqType   = *(int32_t*)((uint8_t*)item + 0x2c);
                            int32_t level    = *(int32_t*)((uint8_t*)item + 0x1c);
                            void* idStringObj= *(void**)  ((uint8_t*)item + 0x10);
                            if (rareType < g_autoEquipQuality) continue;
                            bool shouldEquip = true;
                            ScanEquipmentList(*(void**)((uint8_t*)eqObj + 0x80), eqType, rareType, level, shouldEquip);
                            if (shouldEquip) {
                                ScanEquipmentList(*(void**)((uint8_t*)eqObj + 0xa0), eqType, rareType, level, shouldEquip);
                            }
                            if (shouldEquip && idStringObj) {
                                static void* requestUseItemMI = nullptr;
                                static void* pbKlass = nullptr;
                                if (!pbKlass) pbKlass = ScanFindClass("", "PlayerBehavior");
                                if (pbKlass && !requestUseItemMI)
                                    requestUseItemMI = FindMethodInHierarchy(pbKlass, "RequestUseItem", 3);
                                if (requestUseItemMI) {
                                    int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                                    void* passStr = IL2CPP::il2cpp_string_new("");
                                    void* params[3] = { idStringObj, &apiToken, passStr };
                                    SafeInvoke(requestUseItemMI, playerObj, params);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Auto Sell Key (Tự động bán chìa khoá khi đào được)
    if (g_autoSellKey && playerObj) {
        static double lastSellKeyTime = 0;
        double nowSellKeyTime = [[NSProcessInfo processInfo] systemUptime];
        if (nowSellKeyTime - lastSellKeyTime >= 1.0) {
            lastSellKeyTime = nowSellKeyTime;
            void* invObj = *(void**)((uint8_t*)playerObj + 0x318); // characterInventory
            if (invObj) {
                void* invList = *(void**)((uint8_t*)invObj + 0x80); // localEquipments
                if (invList) {
                    void* arr = *(void**)((uint8_t*)invList + 0x10);
                    int32_t size = *(int32_t*)((uint8_t*)invList + 0x18);
                    if (arr && size > 0) {
                        for (int i = 0; i < size; i++) {
                            void* item = *((void**)((uint8_t*)arr + 0x20) + i);
                            if (!item) continue;
                            int32_t eqType = *(int32_t*)((uint8_t*)item + 0x2c);
                            if (eqType == 13) { // EquipmentType::Key
                                bool isLock = *(bool*)((uint8_t*)item + 0x38);
                                if (isLock) continue;
                                void* idStringObj = *(void**)((uint8_t*)item + 0x10);
                                if (idStringObj) {
                                    int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                                    static void* requestSellKeyMI = nullptr;
                                    static void* pbKlass = nullptr;
                                    if (!pbKlass) pbKlass = ScanFindClass("", "PlayerBehavior");
                                    if (pbKlass && !requestSellKeyMI)
                                        requestSellKeyMI = FindMethodInHierarchy(pbKlass, "RequestSellItem", 2);
                                    if (requestSellKeyMI) {
                                        void* params[2] = { idStringObj, &apiToken };
                                        SafeInvoke(requestSellKeyMI, playerObj, params);
                                        break; // Sell 1 key per check
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Auto Sell Ingredients (Tự động bán nguyên liệu trong túi nguyên liệu)
    if (g_autoSellIngredient && playerObj) {
        static double lastSellTime = 0;
        double nowSellTime = [[NSProcessInfo processInfo] systemUptime];
        if (nowSellTime - lastSellTime >= 2.0) {
            lastSellTime = nowSellTime;
            void* ingredientObj = *(void**)((uint8_t*)playerObj + 0x320); // characterIngredient
            if (ingredientObj) {
                void* listObj = *(void**)((uint8_t*)ingredientObj + 0x80); // localEquipments
                if (listObj) {
                    void* arr = *(void**)((uint8_t*)listObj + 0x10);
                    int32_t size = *(int32_t*)((uint8_t*)listObj + 0x18);
                    if (arr && size > 0) {
                        for (int i = 0; i < size; i++) {
                            void* item = *((void**)((uint8_t*)arr + 0x20) + i);
                            if (!item) continue;
                            bool isLock = *(bool*)((uint8_t*)item + 0x38);
                            if (isLock) continue;
                            int32_t rareType = *(int32_t*)((uint8_t*)item + 0x28);
                            if (rareType <= g_autoSellIngredientQuality) {
                                void* idStringObj = *(void**)((uint8_t*)item + 0x10);
                                if (idStringObj) {
                                    int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                                    static void* requestSellItemMI = nullptr;
                                    static void* pbKlass = nullptr;
                                    if (!pbKlass) pbKlass = ScanFindClass("", "PlayerBehavior");
                                    if (pbKlass && !requestSellItemMI)
                                        requestSellItemMI = FindMethodInHierarchy(pbKlass, "RequestSellItem", 2);
                                    if (requestSellItemMI) {
                                        void* params[2] = { idStringObj, &apiToken };
                                        SafeInvoke(requestSellItemMI, playerObj, params);
                                        break; // Sell 1 item per tick
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Recipe Auto Merge Ingredients (Tự động ghép đá theo công thức)
    bool recipeMergedThisTick = false;
    static double s_campfireArriveTime = 0;
    static double s_campfireRetryCooldown = 0;
    double nowTickTime = [[NSProcessInfo processInfo] systemUptime];

    if (g_recipeMergeEnabled && g_currentRecipe.valid && playerObj) {
        bool canMergeAtLocation = true;
        if (g_recipeMergeGoToFire) {
            Vector3 firePos;
            float fireDist = 999999.0f;
            if (GetClosestFireCraftPosition(playerPos, &firePos, &fireDist)) {
                // If campfire is found on map, only merge when arrived at campfire or within 4.5m
                if (!g_isAtFireForRecipe && fireDist > 4.5f) {
                    canMergeAtLocation = false;
                }
            }
        }

        if (canMergeAtLocation) {
            static double lastRecipeMergeTime = 0;
            double nowRecipeMergeTime = nowTickTime;
            if (nowRecipeMergeTime - lastRecipeMergeTime >= 1.5) {
                lastRecipeMergeTime = nowRecipeMergeTime;
                std::vector<void*> matchedIds;
                if (CheckIfRecipeFormulaReady(playerObj, &matchedIds) && !matchedIds.empty()) {
                    void* pbKlass = ScanFindClass("", "PlayerBehavior");
                    void* mergeMI = GetMergeIngredientMethod(pbKlass);
                    if (mergeMI) {
                        void* listObj = CreateIl2CppStringList(matchedIds, playerObj, mergeMI);
                        if (listObj) {
                            int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                            bool sent = InvokeMergeIngredient(playerObj, listObj, apiToken);
                            if (sent) {
                                recipeMergedThisTick = true;
                                NSLog(@"[THTweak] Successfully sent merge request with %lu stones!", (unsigned long)matchedIds.size());
                                if (g_window) [g_window setStatusText:[NSString stringWithFormat:@"Đã gửi ghép %lu viên đá!", (unsigned long)matchedIds.size()]];
                            }
                        } else {
                            NSLog(@"[THTweak] ERROR: Could not create List<string> for merge!");
                            if (g_window) [g_window setStatusText:@"Lỗi: Không tạo được danh sách đá!"];
                        }
                    } else {
                        NSLog(@"[THTweak] ERROR: No merge method found in PlayerBehavior!");
                        if (g_window) [g_window setStatusText:@"Lỗi: Không tìm thấy hàm ghép đá!"];
                    }
                }
            }
        }
    }

    // Auto Merge Ingredients (Tự động ghép đá / nguyên liệu trong túi nguyên liệu)
    if (g_autoMergeIngredient && !recipeMergedThisTick && (!g_recipeMergeEnabled || !g_currentRecipe.valid) && playerObj) {
        static double lastMergeTime = 0;
        double nowMergeTime = [[NSProcessInfo processInfo] systemUptime];
        if (nowMergeTime - lastMergeTime >= 1.5) {
            lastMergeTime = nowMergeTime;
            void* ingredientObj = *(void**)((uint8_t*)playerObj + 0x320); // characterIngredient
            if (ingredientObj) {
                void* listObj = *(void**)((uint8_t*)ingredientObj + 0x80); // localEquipments
                if (listObj) {
                    void* arr = *(void**)((uint8_t*)listObj + 0x10);
                    int32_t size = *(int32_t*)((uint8_t*)listObj + 0x18);
                    if (arr && size >= 3) {
                        void* matchIds[3] = { nullptr, nullptr, nullptr };
                        bool foundTrio = false;

                        for (int i = 0; i < size; i++) {
                            void* item1 = *((void**)((uint8_t*)arr + 0x20) + i);
                            if (!item1) continue;
                            bool isLock1 = *(bool*)((uint8_t*)item1 + 0x38);
                            if (isLock1) continue;
                            int32_t rare1 = *(int32_t*)((uint8_t*)item1 + 0x28);
                            if (rare1 > g_autoMergeIngredientQuality) continue;
                            int32_t id1 = *(int32_t*)((uint8_t*)item1 + 0x18);
                            int32_t lvl1 = *(int32_t*)((uint8_t*)item1 + 0x1c);
                            void* str1 = *(void**)((uint8_t*)item1 + 0x10);
                            if (!str1) continue;

                            int count = 1;
                            matchIds[0] = str1;

                            for (int j = i + 1; j < size; j++) {
                                void* item2 = *((void**)((uint8_t*)arr + 0x20) + j);
                                if (!item2) continue;
                                bool isLock2 = *(bool*)((uint8_t*)item2 + 0x38);
                                if (isLock2) continue;
                                int32_t rare2 = *(int32_t*)((uint8_t*)item2 + 0x28);
                                if (rare2 != rare1) continue;
                                int32_t id2 = *(int32_t*)((uint8_t*)item2 + 0x18);
                                int32_t lvl2 = *(int32_t*)((uint8_t*)item2 + 0x1c);
                                if (id2 != id1 || lvl2 != lvl1) continue;
                                void* str2 = *(void**)((uint8_t*)item2 + 0x10);
                                if (!str2) continue;

                                matchIds[count++] = str2;
                                if (count == 3) {
                                    foundTrio = true;
                                    break;
                                }
                            }
                            if (foundTrio) break;
                        }

                        if (foundTrio) {
                            void* pbKlass = ScanFindClass("", "PlayerBehavior");
                            void* mergeMI = GetMergeIngredientMethod(pbKlass);
                            if (mergeMI) {
                                std::vector<void*> trio = { matchIds[0], matchIds[1], matchIds[2] };
                                void* mergeList = CreateIl2CppStringList(trio, playerObj, mergeMI);
                                if (mergeList) {
                                    int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                                    InvokeMergeIngredient(playerObj, mergeList, apiToken);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Target scanning
    Vector3 targetPos = playerPos;
    bool hasTarget = false, isTargetMob = false;
    float closestDist = 999999.0f;
    void* targetMobObj = nullptr;

    // Return to death position logic
    if (g_returnToDeathPos && g_hasDeathPos) {
        float dx = g_deathPos.x - playerPos.x;
        float dy = g_deathPos.y - playerPos.y;
        float boxDist = fmaxf(fabsf(dx), fabsf(dy));
        if (boxDist > 1.5f) {
            targetPos = g_deathPos;
            hasTarget = true;
            closestDist = boxDist;
            isTargetMob = false;
        } else {
            g_hasDeathPos = false; // Arrived back at death position!
        }
    }

    // Recipe Campfire Navigation logic
    g_isGoingToFire = false;
    g_isAtFireForRecipe = false;
    g_isReturningToFarm = false;
    if (!g_recipeMergeEnabled || !g_recipeMergeGoToFire || !g_currentRecipe.valid) {
        g_hasFarmPosBeforeFire = false;
        s_campfireArriveTime = 0;
    }
    if (!hasTarget && g_recipeMergeEnabled && g_recipeMergeGoToFire && g_currentRecipe.valid && playerObj) {
        bool formulaReady = CheckIfRecipeFormulaReady(playerObj, nullptr);

        // Safety timeout: if standing at campfire for > 8s and stones are still not consumed, force return to farm
        bool timedOutAtFire = false;
        if (s_campfireArriveTime > 0 && (nowTickTime - s_campfireArriveTime > 8.0)) {
            timedOutAtFire = true;
            s_campfireRetryCooldown = nowTickTime + 15.0; // Wait 15s before attempting campfire again
            s_campfireArriveTime = 0;
            NSLog(@"[THTweak] WARNING: Campfire merge timed out after 8s! Returning to farm...");
        }

        if (formulaReady && !timedOutAtFire && nowTickTime > s_campfireRetryCooldown) {
            Vector3 closestFirePos;
            float fireDist = 999999.0f;
            if (GetClosestFireCraftPosition(playerPos, &closestFirePos, &fireDist)) {
                // Save current farming spot before traveling to fire
                if (!g_hasFarmPosBeforeFire) {
                    if (g_lockDigPos && g_hasLockedPos) {
                        g_farmPosBeforeFire = g_lockedDigPos;
                        g_hasFarmPosBeforeFire = true;
                    } else if (fireDist > 4.0f) {
                        g_farmPosBeforeFire = playerPos;
                        g_hasFarmPosBeforeFire = true;
                    }
                }
                targetPos = closestFirePos;
                hasTarget = true;
                closestDist = fireDist;
                isTargetMob = false;
                g_currentTargetObj = nullptr;
                if (fireDist > 3.8f) {
                    g_isGoingToFire = true;
                    g_isAtFireForRecipe = false;
                    s_campfireArriveTime = 0;
                } else {
                    g_isGoingToFire = false;
                    g_isAtFireForRecipe = true;
                    if (s_campfireArriveTime == 0) s_campfireArriveTime = nowTickTime;
                }
            }
        } else {
            // Recipe formula is NOT ready (crafting completed or ingredients exhausted or timed out):
            s_campfireArriveTime = 0;
            // Return back to the original farm position!
            Vector3 returnTarget = {0,0,0};
            bool shouldReturn = false;
            if (g_hasFarmPosBeforeFire) {
                returnTarget = g_farmPosBeforeFire;
                shouldReturn = true;
            } else if (g_lockDigPos && g_hasLockedPos) {
                returnTarget = g_lockedDigPos;
                shouldReturn = true;
            }
            if (shouldReturn) {
                float dx = returnTarget.x - playerPos.x;
                float dy = returnTarget.y - playerPos.y;
                float retDist = sqrtf(dx * dx + dy * dy);
                if (retDist > 1.2f) {
                    targetPos = returnTarget;
                    hasTarget = true;
                    closestDist = retDist;
                    isTargetMob = false;
                    g_currentTargetObj = nullptr;
                    g_isReturningToFarm = true;
                } else {
                    // Arrived back at the original farming spot!
                    g_hasFarmPosBeforeFire = false;
                    g_isReturningToFarm = false;
                }
            }
        }
    }

    if (!hasTarget) {
        // Attack mobs
    if (g_autoAttackMobs) {
        static void* mobKlass = nullptr;
        if (!mobKlass) mobKlass = ScanFindClass("", "MobBehavior");
        if (mobKlass) {
            int32_t mobCount = 0;
            void* mobArr = Il2cppFindObjects(mobKlass, &mobCount);
            void* closestMob = nullptr;
            Vector3 closestMobPos = {0,0,0};
            float minMobDist = g_attackRangeValue;
            if (mobArr && mobCount > 0) {
                for (int i = 0; i < mobCount; i++) {
                    void* mob = GetArrElem(mobArr, i);
                    if (!mob) continue;
                    if (g_avoidBoss && IsBossMob(mob, playerObj)) continue;
                    if (!IsMobMatchingFilter(mob, g_mobFilterEnabled, g_selectedMobCategory, g_customMobFilterIds, g_customMobFilterName)) continue;
                    void* mobHealth = *(void**)((uint8_t*)mob + 0x1d0);
                    if (!mobHealth) continue;
                    int32_t currentHp = *(int32_t*)((uint8_t*)mobHealth + 0x68);
                    int32_t maxHp = *(int32_t*)((uint8_t*)mobHealth + 0x6c);
                    if (currentHp <= 0) continue;
                    
                    // HP Filter Mode Checks
                    if (g_attackMobFilterMin && (float)maxHp < g_attackMobMinHp) continue;
                    if (g_attackMobFilterMax && (float)maxHp > g_attackMobMaxHp) continue;

                    void* mobTrans = SafeInvoke(getTransformMI, mob, nullptr);
                    if (!mobTrans) continue;
                    void* boxed = SafeInvoke(getPositionMI, mobTrans, nullptr);
                    if (!boxed) continue;
                    Vector3 mobPos = *(Vector3*)((uint8_t*)boxed + 16);
                    if (g_lockDigPos && g_hasLockedPos) {
                        float dxFromLocked = mobPos.x - g_lockedDigPos.x;
                        float dyFromLocked = mobPos.y - g_lockedDigPos.y;
                        float distFromLocked = sqrtf(dxFromLocked*dxFromLocked + dyFromLocked*dyFromLocked);
                        if (distFromLocked > g_lockedDigRange) continue;
                    }
                    float dx = mobPos.x - playerPos.x, dy = mobPos.y - playerPos.y;
                    float dist = sqrtf(dx*dx + dy*dy);
                    if (dist < minMobDist) { minMobDist=dist; closestMob=mob; closestMobPos=mobPos; }
                }
            }
            if (closestMob) {
                targetPos=closestMobPos; hasTarget=true; isTargetMob=true;
                closestDist=minMobDist; targetMobObj=closestMob;
                *(void**)((uint8_t*)playerObj + 0x1c0) = closestMob;
            } else {
                *(void**)((uint8_t*)playerObj + 0x1c0) = nullptr;
            }
        }
    } else {
        *(void**)((uint8_t*)playerObj + 0x1c0) = nullptr;
    }

    // Auto Dig — Skip tiles that have alive mobs nearby (when avoidance is ON) + Sticky Targeting
    if (!hasTarget && g_autoDig) {
        static void* mapObjectKlass = nullptr;
        if (!mapObjectKlass) mapObjectKlass = ScanFindClass("", "MapObject");
        if (mapObjectKlass) {
            // Pre-collect alive mob positions for tile-safety check
            struct MobPos { float x, y; };
            static MobPos mobPosCache[64];
            int mobPosCount = 0;
            if (g_autoAvoidMobs) {
                static void* mobKlassForDig = nullptr;
                if (!mobKlassForDig) mobKlassForDig = ScanFindClass("", "MobBehavior");
                if (mobKlassForDig) {
                    int32_t mc = 0;
                    void* ma = Il2cppFindObjects(mobKlassForDig, &mc);
                    for (int mi = 0; mi < mc && mobPosCount < 64; mi++) {
                        void* mob = GetArrElem(ma, mi);
                        if (!mob) continue;
                        if (g_avoidMobFilterEnabled && !IsMobMatchingFilter(mob, true, g_selectedAvoidMobCategory, g_customAvoidMobFilterIds, g_customAvoidMobFilterName)) continue;
                        void* mobHealth = *(void**)((uint8_t*)mob + 0x1d0);
                        if (!mobHealth || *(int32_t*)((uint8_t*)mobHealth + 0x68) <= 0) continue;
                        void* mobTr = SafeInvoke(getTransformMI, mob, nullptr);
                        if (!mobTr) continue;
                        void* bx = SafeInvoke(getPositionMI, mobTr, nullptr);
                        if (!bx) continue;
                        Vector3 mp = *(Vector3*)((uint8_t*)bx + 16);
                        mobPosCache[mobPosCount++] = { mp.x, mp.y };
                    }
                }
            }

            bool stickValid = false;

            // Timeout check for sticky target: if standing at target for > 3.0 seconds, skip it and find another one
            if (g_currentTargetObj && g_isAtTarget) {
                double now = [[NSProcessInfo processInfo] systemUptime];
                if (now - g_targetStartTime > 3.0) {
                    g_lastFailedTile = g_currentTargetObj;
                    g_currentTargetObj = nullptr;
                    g_isAtTarget = false;
                }
            }

            // Check if current sticky target is still valid
            if (g_currentTargetObj) {
                // Ensure g_currentTargetObj is still in the active MapObjects array to prevent stale pointer crashes
                int32_t checkCount = 0;
                void* checkArr = Il2cppFindObjects(mapObjectKlass, &checkCount);
                bool foundInList = false;
                if (checkArr && checkCount > 0) {
                    for (int c = 0; c < checkCount; c++) {
                        if (GetArrElem(checkArr, c) == g_currentTargetObj) {
                            foundInList = true;
                            break;
                        }
                    }
                }

                if (foundInList) {
                    void* mapData = *(void**)((uint8_t*)g_currentTargetObj + 0x20);
                    if (mapData && *(int32_t*)((uint8_t*)mapData + 0x1c) > 0) {
                        void* trans = SafeInvoke(getTransformMI, g_currentTargetObj, nullptr);
                        if (trans) {
                            void* boxed = SafeInvoke(getPositionMI, trans, nullptr);
                            if (boxed) {
                                Vector3 pos = *(Vector3*)((uint8_t*)boxed + 16);
                                float dx = pos.x - playerPos.x;
                                float dy = pos.y - playerPos.y;
                                float dist = sqrtf(dx*dx + dy*dy);
                                if (dist <= g_digRangeValue) {
                                    if (g_lockDigPos && g_hasLockedPos) {
                                        float dxFromLocked = pos.x - g_lockedDigPos.x;
                                        float dyFromLocked = pos.y - g_lockedDigPos.y;
                                        float distFromLocked = sqrtf(dxFromLocked*dxFromLocked + dyFromLocked*dyFromLocked);
                                        if (distFromLocked <= g_lockedDigRange) {
                                            stickValid = true;
                                            targetPos = pos;
                                            hasTarget = true;
                                            closestDist = dist;
                                        }
                                    } else {
                                        stickValid = true;
                                        targetPos = pos;
                                        hasTarget = true;
                                        closestDist = dist;
                                    }
                                }
                            }
                        }
                    }
                }
                if (!stickValid) {
                    g_currentTargetObj = nullptr;
                    g_isAtTarget = false;
                }
            }

            // If no valid sticky target, scan for closest tile
            if (!g_currentTargetObj) {
                int32_t mapCount = 0;
                void* mapArr = Il2cppFindObjects(mapObjectKlass, &mapCount);
                void* closestMapObj = nullptr;
                Vector3 closestTilePos = {0,0,0};
                float minTileDist = g_digRangeValue;

                if (mapArr && mapCount > 0) {
                    for (int i = 0; i < mapCount; i++) {
                        void* mapObj = GetArrElem(mapArr, i);
                        if (!mapObj || mapObj == g_lastFailedTile) continue;
                        void* mapData = *(void**)((uint8_t*)mapObj + 0x20);
                        if (!mapData || *(int32_t*)((uint8_t*)mapData + 0x1c) <= 0) continue;
                        void* trans = SafeInvoke(getTransformMI, mapObj, nullptr);
                        if (!trans) continue;
                        void* boxed = SafeInvoke(getPositionMI, trans, nullptr);
                        if (!boxed) continue;
                        Vector3 pos = *(Vector3*)((uint8_t*)boxed + 16);
                        
                        if (g_lockDigPos && g_hasLockedPos) {
                            float dxFromLocked = pos.x - g_lockedDigPos.x;
                            float dyFromLocked = pos.y - g_lockedDigPos.y;
                            float distFromLocked = sqrtf(dxFromLocked*dxFromLocked + dyFromLocked*dyFromLocked);
                            if (distFromLocked > g_lockedDigRange) continue;
                        }

                        float dx = pos.x - playerPos.x, dy = pos.y - playerPos.y;
                        float dist = sqrtf(dx*dx + dy*dy);
                        if (dist > minTileDist) continue;

                        // Check if tile is dangerously close to an alive mob
                        if (g_autoAvoidMobs && mobPosCount > 0) {
                            bool tileBlocked = false;
                            float checkRadius = g_avoidRangeValue * 0.85f;
                            for (int mi = 0; mi < mobPosCount; mi++) {
                                float mx = pos.x - mobPosCache[mi].x;
                                float my = pos.y - mobPosCache[mi].y;
                                if (sqrtf(mx*mx + my*my) < checkRadius) { tileBlocked=true; break; }
                            }
                            if (tileBlocked) continue;
                        }

                        minTileDist=dist; closestMapObj=mapObj; closestTilePos=pos;
                    }
                }
                if (closestMapObj) {
                    targetPos=closestTilePos; hasTarget=true; closestDist=minTileDist;
                    if (g_currentTargetObj != closestMapObj) {
                        g_currentTargetObj = closestMapObj;
                        g_isAtTarget = false; // Reset reached state for new target!
                        g_lastFailedTile = nullptr; // Reset failed tile since we selected a new target!
                    }
                }
            }
        }
    }
}
    if (!g_isGoingToFire && !g_isAtFireForRecipe && !g_isReturningToFarm && g_lockDigPos && g_hasLockedPos) {
        float playerDx = playerPos.x - g_lockedDigPos.x;
        float playerDy = playerPos.y - g_lockedDigPos.y;
        float playerDistFromLocked = sqrtf(playerDx*playerDx + playerDy*playerDy);
        if (playerDistFromLocked > g_lockedDigRange) {
            targetPos = g_lockedDigPos;
            hasTarget = true;
            isTargetMob = false;
            targetMobObj = nullptr;
            closestDist = playerDistFromLocked;
            g_currentTargetObj = nullptr;
        }
    }

    g_cachedTargetPos   = targetPos;
    g_hasCachedTarget   = hasTarget;
    g_cachedTargetIsMob = isTargetMob;
    g_cachedClosestDist = closestDist;
    g_cachedMobObj      = targetMobObj;

    // Avoid mobs repulsion
    s_hasAvoidForces = false; s_avoidX = 0.0f; s_avoidY = 0.0f;
    if (g_autoAvoidMobs) {
        static void* mobKlass = nullptr;
        if (!mobKlass) mobKlass = ScanFindClass("", "MobBehavior");
        if (mobKlass) {
            int32_t mobCount = 0;
            void* mobArr = Il2cppFindObjects(mobKlass, &mobCount);
            if (mobArr && mobCount > 0) {
                for (int i = 0; i < mobCount; i++) {
                    void* mob = GetArrElem(mobArr, i);
                    if (!mob || (isTargetMob && mob == targetMobObj)) continue;
                    if (g_avoidMobFilterEnabled && !IsMobMatchingFilter(mob, true, g_selectedAvoidMobCategory, g_customAvoidMobFilterIds, g_customAvoidMobFilterName)) continue;
                    void* mobHealth = *(void**)((uint8_t*)mob + 0x1d0);
                    if (!mobHealth || *(int32_t*)((uint8_t*)mobHealth + 0x68) <= 0) continue;
                    void* mobTrans = SafeInvoke(getTransformMI, mob, nullptr);
                    if (!mobTrans) continue;
                    void* boxed = SafeInvoke(getPositionMI, mobTrans, nullptr);
                    if (!boxed) continue;
                    Vector3 mobPos = *(Vector3*)((uint8_t*)boxed + 16);
                    float mdx = playerPos.x - mobPos.x, mdy = playerPos.y - mobPos.y;
                    float mdist = sqrtf(mdx*mdx + mdy*mdy);
                    if (mdist < g_avoidRangeValue) {
                        if (mdist < 0.1f) mdist = 0.1f;
                        float force = (g_avoidRangeValue - mdist) * 2.5f;
                        s_avoidX += (mdx / mdist) * force;
                        s_avoidY += (mdy / mdist) * force;
                        s_hasAvoidForces = true;
                    }
                }
            }
        }
    }

    // Avoid players repulsion and Auto quit near player
    if (g_avoidPlayers || g_autoQuitNearPlayer) {
        static void* pbKlassForScan = nullptr;
        if (!pbKlassForScan) pbKlassForScan = ScanFindClass("", "PlayerBehavior");
        if (pbKlassForScan) {
            int32_t pCount = 0;
            void* pArr = Il2cppFindObjects(pbKlassForScan, &pCount);
            if (pArr && pCount > 0) {
                for (int pi = 0; pi < pCount; pi++) {
                    void* otherP = GetArrElem(pArr, pi);
                    if (!otherP || otherP == playerObj || !IsValidUnityObj(otherP)) continue;
                    void* pHealth = *(void**)((uint8_t*)otherP + 0x1d0);
                    if (pHealth && *(int32_t*)((uint8_t*)pHealth + 0x68) <= 0) continue;
                    void* pTr = SafeInvoke(getTransformMI, otherP, nullptr);
                    if (!pTr) continue;
                    void* pBx = SafeInvoke(getPositionMI, pTr, nullptr);
                    if (!pBx) continue;
                    Vector3 otherPos = *(Vector3*)((uint8_t*)pBx + 16);
                    float pdx = playerPos.x - otherPos.x;
                    float pdy = playerPos.y - otherPos.y;
                    float pdist = sqrtf(pdx * pdx + pdy * pdy);
                    
                    // 1. Auto quit when other player in range
                    if (g_autoQuitNearPlayer && pdist <= g_autoQuitPlayerRange && pdist > 0.05f) {
                        NSLog(@"[THTweak] WARNING: Other player detected at distance %.2fm! Auto-quitting game to protect account...", pdist);
                        exit(0);
                        return;
                    }
                    
                    // 2. Repulsive avoidance force from other players
                    if (g_avoidPlayers && pdist < g_avoidPlayerRange) {
                        if (pdist < 0.1f) pdist = 0.1f;
                        float force = (g_avoidPlayerRange - pdist) * 3.0f;
                        s_avoidX += (pdx / pdist) * force;
                        s_avoidY += (pdy / pdist) * force;
                        s_hasAvoidForces = true;
                    }
                }
            }
        }
    }

    // Trigger network requests at 0.3s interval instead of 60FPS to prevent lag
    if (hasTarget && playerObj) {
        bool inDigRange = false;
        bool isCampfireNav = (g_isGoingToFire || g_isAtFireForRecipe || g_isReturningToFarm);
        if (!isTargetMob && !isCampfireNav) {
            float dx = targetPos.x - playerPos.x;
            float dy = targetPos.y - playerPos.y;
            float boxDist = fmaxf(fabsf(dx), fabsf(dy));
            if (g_isAtTarget || boxDist <= 0.65f) inDigRange = true;
        }
        if (inDigRange) {
            static void* requestSetTargetFarmMI = nullptr;
            static void* playerBehaviorKlass = nullptr;
            if (!playerBehaviorKlass) playerBehaviorKlass = ScanFindClass("", "PlayerBehavior");
            if (playerBehaviorKlass && !requestSetTargetFarmMI)
                requestSetTargetFarmMI = FindMethodInHierarchy(playerBehaviorKlass, "RequestSetTargetFarm", 2);
            if (requestSetTargetFarmMI) {
                int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                Vector2 targetPosVec = { targetPos.x, targetPos.y };
                void* params[2] = { &apiToken, &targetPosVec };
                SafeInvoke(requestSetTargetFarmMI, playerObj, params);
            }
        }
        if (isTargetMob && closestDist <= 1.8f) {
            static void* requestUseSkillMI = nullptr;
            static void* playerBehaviorKlass = nullptr;
            if (!playerBehaviorKlass) playerBehaviorKlass = ScanFindClass("", "PlayerBehavior");
            if (playerBehaviorKlass && !requestUseSkillMI)
                requestUseSkillMI = FindMethodInHierarchy(playerBehaviorKlass, "RequestUseSkill", 1);
            if (requestUseSkillMI) {
                int32_t apiToken = *(int32_t*)((uint8_t*)playerObj + 0x29c);
                void* params[1] = { &apiToken };
                SafeInvoke(requestUseSkillMI, playerObj, params);
            }
        }
    }
}

// =============================================
// UI Colors & Sizing
// =============================================
#define PANEL_W 290.0f
#define PANEL_H 510.0f
#define CLR_BG    [UIColor colorWithRed:0.05 green:0.05 blue:0.09 alpha:0.96]
#define CLR_ROW   [UIColor colorWithRed:0.11 green:0.11 blue:0.20 alpha:0.50]
#define CLR_PURP  [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:1.0]
#define CLR_GREEN [UIColor colorWithRed:0.20 green:0.95 blue:0.55 alpha:1.0]

static UILabel* MakeLabel(NSString* text, CGRect frame, CGFloat size, UIColor* color) {
    UILabel* l = [[UILabel alloc] initWithFrame:frame];
    l.text = text;
    l.textColor = color;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
    l.adjustsFontSizeToFitWidth = YES;
    return l;
}
static UISlider* MakeSlider(CGRect frame, float min, float max, float val) {
    UISlider* s = [[UISlider alloc] initWithFrame:frame];
    s.minimumValue = min; s.maximumValue = max; s.value = val;
    s.minimumTrackTintColor = CLR_GREEN;
    return s;
}
static UIView* MakeRow(CGRect frame) {
    UIView* v = [[UIView alloc] initWithFrame:frame];
    v.backgroundColor = CLR_ROW;
    v.layer.cornerRadius = 6.0f;
    return v;
}
static UISwitch* MakeSwitch(CGFloat x, CGFloat y, bool on) {
    UISwitch* sw = [[UISwitch alloc] initWithFrame:CGRectMake(x, y, 51, 31)];
    sw.on = on;
    sw.onTintColor = CLR_PURP;
    return sw;
}

// =============================================
// UI Implementation
// =============================================
@implementation THTweakWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || (self.rootViewController && hitView == self.rootViewController.view))
        return nil;
    return hitView;
}

- (void)attachWindowSceneIfNeeded {
    if (@available(iOS 13.0, *)) {
        if (!self.windowScene) {
            UIWindowScene *scene = GetActiveWindowScene();
            if (scene) {
                self.windowScene = scene;
            }
        }
    }
}

- (instancetype)init {
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (!self) return nil;

    LoadTweakPreferences();

    [self attachWindowSceneIfNeeded];

    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor clearColor];
    vc.view.frame = self.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.rootViewController = vc;

    self.windowLevel            = UIWindowLevelAlert + 100;
    self.backgroundColor        = UIColor.clearColor;
    self.userInteractionEnabled = YES;
    self.hidden                 = NO;

    // Range visualizer shape layers
    _digRangeLayer = [CAShapeLayer layer];
    _digRangeLayer.fillColor = [UIColor clearColor].CGColor;
    _digRangeLayer.lineWidth = 1.5f;
    _digRangeLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.85 blue:0.20 alpha:0.75].CGColor; // Gold
    _digRangeLayer.lineDashPattern = @[@5, @4];
    [self.layer insertSublayer:_digRangeLayer atIndex:0];

    _lockDigRangeLayer = [CAShapeLayer layer];
    _lockDigRangeLayer.fillColor = [UIColor clearColor].CGColor;
    _lockDigRangeLayer.lineWidth = 1.5f;
    _lockDigRangeLayer.strokeColor = [UIColor colorWithRed:0.20 green:0.95 blue:0.55 alpha:0.75].CGColor; // Green
    _lockDigRangeLayer.lineDashPattern = @[@7, @5];
    [self.layer insertSublayer:_lockDigRangeLayer atIndex:1];

    _attackRangeLayer = [CAShapeLayer layer];
    _attackRangeLayer.fillColor = [UIColor clearColor].CGColor;
    _attackRangeLayer.lineWidth = 1.5f;
    _attackRangeLayer.strokeColor = [UIColor colorWithRed:0.75 green:0.40 blue:1.0 alpha:0.75].CGColor; // Purple
    _attackRangeLayer.lineDashPattern = @[@5, @4];
    [self.layer insertSublayer:_attackRangeLayer atIndex:2];

    _mobAvoidRangeLayer = [CAShapeLayer layer];
    _mobAvoidRangeLayer.fillColor = [UIColor clearColor].CGColor;
    _mobAvoidRangeLayer.lineWidth = 1.5f;
    _mobAvoidRangeLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.55 blue:0.15 alpha:0.75].CGColor; // Orange
    _mobAvoidRangeLayer.lineDashPattern = @[@5, @4];
    [self.layer insertSublayer:_mobAvoidRangeLayer atIndex:3];

    _playerAvoidRangeLayer = [CAShapeLayer layer];
    _playerAvoidRangeLayer.fillColor = [UIColor clearColor].CGColor;
    _playerAvoidRangeLayer.lineWidth = 1.8f;
    _playerAvoidRangeLayer.strokeColor = [UIColor colorWithRed:0.0 green:0.85 blue:1.0 alpha:0.85].CGColor; // Cyan
    _playerAvoidRangeLayer.lineDashPattern = @[@6, @4];
    [self.layer insertSublayer:_playerAvoidRangeLayer atIndex:4];

    _autoQuitRangeLayer = [CAShapeLayer layer];
    _autoQuitRangeLayer.fillColor = [UIColor clearColor].CGColor;
    _autoQuitRangeLayer.lineWidth = 2.0f;
    _autoQuitRangeLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.20 blue:0.25 alpha:0.90].CGColor; // Bright Red
    _autoQuitRangeLayer.lineDashPattern = @[@4, @3];
    [self.layer insertSublayer:_autoQuitRangeLayer atIndex:5];

    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateESPLine)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    [self attachWindowSceneIfNeeded];
    [self makeKeyAndVisible];
    [self buildUI];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self attachWindowSceneIfNeeded];
}

// =============================================
// Build UI (No ScrollView - flat rows per sub-tab)
// =============================================
- (void)buildUI {
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    CGFloat availableH = fminf(screenBounds.size.width, screenBounds.size.height);
    if (availableH < 300.0f) availableH = 375.0f; // iPhone 7 landscape height is ~375pt

    const CGFloat PW = PANEL_W;
    const CGFloat PH = fminf(PANEL_H, availableH - 20.0f); // Dynamically fit iPhone 7 screen height (e.g. 355pt)
    
    CGFloat panelY = fmaxf(10.0f, (availableH - PH) / 2.0f);
    CGFloat panelX = 60.0f;
    if (panelX + PW > screenBounds.size.width) panelX = 10.0f;

    // Handle button
    UIButton *handle = [UIButton buttonWithType:UIButtonTypeCustom];
    handle.frame = CGRectMake(10, fminf(160, availableH - 60), 44, 44);
    handle.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.13 alpha:0.92];
    handle.layer.cornerRadius = 4.0f;
    handle.layer.borderWidth = 1.5f;
    handle.layer.borderColor = CLR_PURP.CGColor;
    [handle setTitle:@"shiu" forState:UIControlStateNormal];
    [handle setTitleColor:[UIColor colorWithRed:0.80 green:0.60 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    handle.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    [handle addTarget:self action:@selector(togglePanel:) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
    [handle addGestureRecognizer:pan];
    [self addSubview:handle];

    // Panel
    _panel = [[UIView alloc] initWithFrame:CGRectMake(panelX, panelY, PW, PH)];
    _panel.hidden = YES;
    _panel.backgroundColor = CLR_BG;
    _panel.layer.cornerRadius = 10.0f;
    _panel.layer.borderWidth = 1.5f;
    _panel.layer.borderColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.70].CGColor;
    _panel.clipsToBounds = YES;
    UIPanGestureRecognizer *panPanel = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPanel:)];
    [_panel addGestureRecognizer:panPanel];

    // Main tab: Tự Động | Cài Đặt | Liên Hệ
    _mainTabControl = [[UISegmentedControl alloc] initWithItems:@[@"Tự Động", @"Cài Đặt", @"Liên Hệ"]];
    _mainTabControl.frame = CGRectMake(8, 8, PW-16, 32);
    _mainTabControl.selectedSegmentIndex = 0;
    _mainTabControl.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:0.80];
    [_mainTabControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12]} forState:UIControlStateNormal];
    [_mainTabControl setTitleTextAttributes:@{NSForegroundColorAttributeName:CLR_GREEN, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]} forState:UIControlStateSelected];
    [_mainTabControl addTarget:self action:@selector(mainTabChanged:) forControlEvents:UIControlEventValueChanged];
    [_panel addSubview:_mainTabControl];

    // Divider
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 46, PW, 1)];
    div.backgroundColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.25];
    [_panel addSubview:div];

    // ---- AUTO PAGE ----
    _autoPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 47, PW, PH - 47 - 24)];
    _autoPageView.backgroundColor = [UIColor clearColor];

    // Sub-tab: Đào | Quái | PVP | Hp | Trang bị
    _autoSubTabControl = [[UISegmentedControl alloc] initWithItems:@[@"Đào", @"Quái", @"PVP", @"Hp", @"Đồ"]];
    _autoSubTabControl.frame = CGRectMake(8, 4, PW-16, 28);
    _autoSubTabControl.selectedSegmentIndex = 0;
    _autoSubTabControl.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.14 alpha:0.80];
    [_autoSubTabControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.75 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:10.5]} forState:UIControlStateNormal];
    [_autoSubTabControl setTitleTextAttributes:@{NSForegroundColorAttributeName:CLR_PURP, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.5]} forState:UIControlStateSelected];
    [_autoSubTabControl addTarget:self action:@selector(autoSubTabChanged:) forControlEvents:UIControlEventValueChanged];
    [_autoPageView addSubview:_autoSubTabControl];

    const CGFloat subY = 38.0f;
    const CGFloat subH = PH - 47 - 24 - subY;
    const CGFloat ROW  = 44.0f;

    // ---- Sub: ĐÀO ----
    UIScrollView *svDao = [[UIScrollView alloc] initWithFrame:CGRectMake(0, subY, PW, subH)];
    svDao.showsVerticalScrollIndicator = YES;
    svDao.alwaysBounceVertical = YES;
    _subDaoView = svDao;
    {
        // Row: toggle
        UIView *r1 = MakeRow(CGRectMake(8, 6, PW-16, ROW));
        UILabel *l1 = MakeLabel(@"Tự đi đào ô gần nhất", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAutoDig = MakeSwitch(PW-16-56, 7, g_autoDig);
        [_swAutoDig addTarget:self action:@selector(swDigChanged:) forControlEvents:UIControlEventValueChanged];
        [r1 addSubview:l1]; [r1 addSubview:_swAutoDig]; [_subDaoView addSubview:r1];

        // Slider row 1: Phạm vi tìm ô
        CGFloat y2 = ROW + 14;
        UIView *r2 = MakeRow(CGRectMake(8, y2, PW-16, 52));
        _lblDigRange = MakeLabel([NSString stringWithFormat:@"Phạm vi tìm ô: %.0fm", g_digRangeValue],
                                  CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderDigRange = MakeSlider(CGRectMake(10, 20, PW-36, 26), 3, 30, g_digRangeValue);
        [_sliderDigRange addTarget:self action:@selector(sliderDigChanged:) forControlEvents:UIControlEventValueChanged];
        [r2 addSubview:_lblDigRange]; [r2 addSubview:_sliderDigRange]; [_subDaoView addSubview:r2];

        // Slider row 2: Dừng tại tâm ô đất
        CGFloat y3 = y2 + 52 + 6;
        UIView *r3 = MakeRow(CGRectMake(8, y3, PW-16, 52));
        _lblDigStopDist = MakeLabel([NSString stringWithFormat:@"Khoảng cách tâm ô: %.2fm", g_digStopDist],
                                     CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderDigStopDist = MakeSlider(CGRectMake(10, 20, PW-36, 26), 0.05f, 0.50f, g_digStopDist);
        [_sliderDigStopDist addTarget:self action:@selector(sliderDigStopDistChanged:) forControlEvents:UIControlEventValueChanged];
        [r3 addSubview:_lblDigStopDist]; [r3 addSubview:_sliderDigStopDist]; [_subDaoView addSubview:r3];

        // Slider row 3: Độ nhạy phanh khi tốc độ thay đổi
        CGFloat y4 = y3 + 52 + 6;
        UIView *r4 = MakeRow(CGRectMake(8, y4, PW-16, 52));
        _lblSpeedSensitivity = MakeLabel([NSString stringWithFormat:@"Độ nhạy phanh (Tốc độ): %.1fx", g_speedSensitivity],
                                          CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderSpeedSensitivity = MakeSlider(CGRectMake(10, 20, PW-36, 26), 0.2f, 3.0f, g_speedSensitivity);
        [_sliderSpeedSensitivity addTarget:self action:@selector(sliderSpeedSensitivityChanged:) forControlEvents:UIControlEventValueChanged];
        [r4 addSubview:_lblSpeedSensitivity]; [r4 addSubview:_sliderSpeedSensitivity]; [_subDaoView addSubview:r4];
        
        // Row: Khóa vị trí đào đất
        CGFloat y5 = y4 + 52 + 6;
        UIView *r5 = MakeRow(CGRectMake(8, y5, PW-16, ROW));
        UILabel *l5 = MakeLabel(@"Khóa vị trí đào đất", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swLockDigPos = MakeSwitch(PW-16-56, 7, g_lockDigPos);
        [_swLockDigPos addTarget:self action:@selector(swLockDigPosChanged:) forControlEvents:UIControlEventValueChanged];
        [r5 addSubview:l5]; [r5 addSubview:_swLockDigPos]; [_subDaoView addSubview:r5];
        
        // Slider row: Bán kính giới hạn đào
        CGFloat y6 = y5 + ROW + 6;
        _rowLockDigRange = MakeRow(CGRectMake(8, y6, PW-16, 52));
        _lblLockDigRange = MakeLabel([NSString stringWithFormat:@"Bán kính farm đá: %.1fm", g_lockedDigRange],
                                      CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderLockDigRange = MakeSlider(CGRectMake(10, 20, PW-36, 26), 1.0f, 150.0f, g_lockedDigRange);
        [_sliderLockDigRange addTarget:self action:@selector(sliderLockDigRangeChanged:) forControlEvents:UIControlEventValueChanged];
        [_rowLockDigRange addSubview:_lblLockDigRange]; [_rowLockDigRange addSubview:_sliderLockDigRange];
        _rowLockDigRange.hidden = !g_lockDigPos;
        [_subDaoView addSubview:_rowLockDigRange];
        
        svDao.contentSize = CGSizeMake(PW, y6 + 52 + 16);
    }
    [_autoPageView addSubview:_subDaoView];

    // ---- Sub: QUÁI ----
    UIScrollView *svQuai = [[UIScrollView alloc] initWithFrame:CGRectMake(0, subY, PW, subH)];
    svQuai.showsVerticalScrollIndicator = YES;
    svQuai.alwaysBounceVertical = YES;
    _subQuaiView = svQuai;
    _subQuaiView.hidden = YES;
    {
        // 1. Attack mobs toggle
        UIView *r1 = MakeRow(CGRectMake(8, 6, PW-16, ROW));
        UILabel *l1 = MakeLabel(@"Tự động đánh quái", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAttackMobs = MakeSwitch(PW-16-56, 7, g_autoAttackMobs);
        [_swAttackMobs addTarget:self action:@selector(swAttackChanged:) forControlEvents:UIControlEventValueChanged];
        [r1 addSubview:l1]; [r1 addSubview:_swAttackMobs]; [_subQuaiView addSubview:r1];

        // 2. Attack range slider
        CGFloat y2 = ROW + 14;
        UIView *rs2 = MakeRow(CGRectMake(8, y2, PW-16, 52));
        _lblAttackRange = MakeLabel([NSString stringWithFormat:@"Phạm vi đánh: %.0fm", g_attackRangeValue],
                                     CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderAttackRange = MakeSlider(CGRectMake(10, 20, PW-36, 26), 3, 30, g_attackRangeValue);
        [_sliderAttackRange addTarget:self action:@selector(sliderAttackChanged:) forControlEvents:UIControlEventValueChanged];
        [rs2 addSubview:_lblAttackRange]; [rs2 addSubview:_sliderAttackRange]; [_subQuaiView addSubview:rs2];

        // 3. Mob Farm Filter row (Lọc quái đánh)
        CGFloat y3 = y2 + 52 + 6;
        UIView *rsMobCat = MakeRow(CGRectMake(8, y3, PW-16, 52));
        UILabel *lblCat = MakeLabel(@"Lọc quái cần đánh (Farm):", CGRectMake(10, 4, PW-36-60, 14), 10, CLR_GREEN);
        _swMobFilterEnabled = MakeSwitch(PW-16-50, 14, g_mobFilterEnabled);
        [_swMobFilterEnabled addTarget:self action:@selector(swMobFilterChanged:) forControlEvents:UIControlEventValueChanged];
        
        _btnMobCategory = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnMobCategory.frame = CGRectMake(10, 22, PW-36-58, 26);
        _btnMobCategory.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:0.80];
        _btnMobCategory.layer.cornerRadius = 4.0f;
        _btnMobCategory.layer.borderWidth = 1.0f;
        _btnMobCategory.layer.borderColor = CLR_PURP.CGColor;
        _btnMobCategory.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0];
        [_btnMobCategory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnMobCategory setTitle:GetMobFilterShortName(g_selectedMobCategory, g_customMobFilterIds, g_customMobFilterName) forState:UIControlStateNormal];
        [_btnMobCategory addTarget:self action:@selector(btnMobCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        [rsMobCat addSubview:lblCat]; [rsMobCat addSubview:_btnMobCategory]; [rsMobCat addSubview:_swMobFilterEnabled];
        [_subQuaiView addSubview:rsMobCat];

        // 4. Avoid mobs toggle
        CGFloat y4 = y3 + 52 + 6;
        UIView *rAvoid = MakeRow(CGRectMake(8, y4, PW-16, ROW));
        UILabel *lAvoid = MakeLabel(@"Tự động né quái", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAvoidMobs = MakeSwitch(PW-16-56, 7, g_autoAvoidMobs);
        [_swAvoidMobs addTarget:self action:@selector(swAvoidChanged:) forControlEvents:UIControlEventValueChanged];
        [rAvoid addSubview:lAvoid]; [rAvoid addSubview:_swAvoidMobs]; [_subQuaiView addSubview:rAvoid];

        // 5. Avoid Range Slider
        CGFloat y5 = y4 + ROW + 6;
        UIView *rsAvoid = MakeRow(CGRectMake(8, y5, PW-16, 52));
        _lblAvoidRange = MakeLabel([NSString stringWithFormat:@"Phạm vi né quái: %.0fm", g_avoidRangeValue],
                                    CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderAvoidRange = MakeSlider(CGRectMake(10, 20, PW-36, 26), 1, 15, g_avoidRangeValue);
        [_sliderAvoidRange addTarget:self action:@selector(sliderAvoidChanged:) forControlEvents:UIControlEventValueChanged];
        [rsAvoid addSubview:_lblAvoidRange]; [rsAvoid addSubview:_sliderAvoidRange]; [_subQuaiView addSubview:rsAvoid];

        // 6. Avoid Mob Filter row (Lọc quái né)
        CGFloat y6 = y5 + 52 + 6;
        UIView *rsAvoidCat = MakeRow(CGRectMake(8, y6, PW-16, 52));
        UILabel *lblAvoidCat = MakeLabel(@"Lọc danh sách quái né:", CGRectMake(10, 4, PW-36-60, 14), 10, CLR_GREEN);
        _swAvoidMobFilterEnabled = MakeSwitch(PW-16-50, 14, g_avoidMobFilterEnabled);
        [_swAvoidMobFilterEnabled addTarget:self action:@selector(swAvoidMobFilterChanged:) forControlEvents:UIControlEventValueChanged];
        
        _btnAvoidMobCategory = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnAvoidMobCategory.frame = CGRectMake(10, 22, PW-36-58, 26);
        _btnAvoidMobCategory.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:0.80];
        _btnAvoidMobCategory.layer.cornerRadius = 4.0f;
        _btnAvoidMobCategory.layer.borderWidth = 1.0f;
        _btnAvoidMobCategory.layer.borderColor = CLR_PURP.CGColor;
        _btnAvoidMobCategory.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0];
        [_btnAvoidMobCategory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnAvoidMobCategory setTitle:GetMobFilterShortName(g_selectedAvoidMobCategory, g_customAvoidMobFilterIds, g_customAvoidMobFilterName) forState:UIControlStateNormal];
        [_btnAvoidMobCategory addTarget:self action:@selector(btnAvoidMobCategoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        [rsAvoidCat addSubview:lblAvoidCat]; [rsAvoidCat addSubview:_btnAvoidMobCategory]; [rsAvoidCat addSubview:_swAvoidMobFilterEnabled];
        [_subQuaiView addSubview:rsAvoidCat];

        // 7. Avoid Boss
        CGFloat y7 = y6 + 52 + 6;
        UIView *rBoss = MakeRow(CGRectMake(8, y7, PW-16, ROW));
        UILabel *lBoss = MakeLabel(@"Né boss không đánh", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAvoidBoss = MakeSwitch(PW-16-56, 7, g_avoidBoss);
        [_swAvoidBoss addTarget:self action:@selector(swAvoidBossChanged:) forControlEvents:UIControlEventValueChanged];
        [rBoss addSubview:lBoss]; [rBoss addSubview:_swAvoidBoss]; [_subQuaiView addSubview:rBoss];

        // 8. Mob Min HP filter row
        CGFloat y8 = y7 + ROW + 6;
        UIView *rsMobMin = MakeRow(CGRectMake(8, y8, PW-16, 52));
        _lblMobMinHp = MakeLabel([NSString stringWithFormat:@"HP quái lớn hơn: %.0f", g_attackMobMinHp],
                                  CGRectMake(10, 4, PW-36-60, 14), 10, CLR_GREEN);
        _sliderMobMinHp = MakeSlider(CGRectMake(10, 20, PW-36-60, 26), 20, 2000, g_attackMobMinHp);
        [_sliderMobMinHp addTarget:self action:@selector(sliderMobMinHpChanged:) forControlEvents:UIControlEventValueChanged];
        UISwitch *swMobMin = MakeSwitch(PW-16-50, 14, g_attackMobFilterMin);
        [swMobMin addTarget:self action:@selector(swMobMinChanged:) forControlEvents:UIControlEventValueChanged];
        [rsMobMin addSubview:_lblMobMinHp]; [rsMobMin addSubview:_sliderMobMinHp]; [rsMobMin addSubview:swMobMin];
        [_subQuaiView addSubview:rsMobMin];

        // 9. Mob Max HP filter row
        CGFloat y9 = y8 + 52 + 6;
        UIView *rsMobMax = MakeRow(CGRectMake(8, y9, PW-16, 52));
        _lblMobMaxHp = MakeLabel([NSString stringWithFormat:@"HP quái nhỏ hơn: %.0f", g_attackMobMaxHp],
                                  CGRectMake(10, 4, PW-36-60, 14), 10, CLR_GREEN);
        _sliderMobMaxHp = MakeSlider(CGRectMake(10, 20, PW-36-60, 26), 20, 2000, g_attackMobMaxHp);
        [_sliderMobMaxHp addTarget:self action:@selector(sliderMobMaxHpChanged:) forControlEvents:UIControlEventValueChanged];
        UISwitch *swMobMax = MakeSwitch(PW-16-50, 14, g_attackMobFilterMax);
        [swMobMax addTarget:self action:@selector(swMobMaxChanged:) forControlEvents:UIControlEventValueChanged];
        [rsMobMax addSubview:_lblMobMaxHp]; [rsMobMax addSubview:_sliderMobMaxHp]; [rsMobMax addSubview:swMobMax];
        [_subQuaiView addSubview:rsMobMax];

        svQuai.contentSize = CGSizeMake(PW, y9 + 52 + 16);
    }
    [_autoPageView addSubview:_subQuaiView];

    // ---- Sub: PVP / NÉ NGƯỜI CHƠI ----
    UIScrollView *svPvp = [[UIScrollView alloc] initWithFrame:CGRectMake(0, subY, PW, subH)];
    svPvp.showsVerticalScrollIndicator = YES;
    svPvp.alwaysBounceVertical = YES;
    _subPvpView = svPvp;
    _subPvpView.hidden = YES;
    {
        // 1. Avoid Players Toggle
        UIView *r1 = MakeRow(CGRectMake(8, 6, PW-16, ROW));
        UILabel *l1 = MakeLabel(@"Tự động né người chơi", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAvoidPlayers = MakeSwitch(PW-16-56, 7, g_avoidPlayers);
        [_swAvoidPlayers addTarget:self action:@selector(swAvoidPlayersChanged:) forControlEvents:UIControlEventValueChanged];
        [r1 addSubview:l1]; [r1 addSubview:_swAvoidPlayers]; [_subPvpView addSubview:r1];

        // 2. Avoid Player Range Slider
        CGFloat y2 = ROW + 14;
        UIView *rs1 = MakeRow(CGRectMake(8, y2, PW-16, 52));
        _lblAvoidPlayerRange = MakeLabel([NSString stringWithFormat:@"Khoảng cách né người: %.0fm", g_avoidPlayerRange],
                                          CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderAvoidPlayerRange = MakeSlider(CGRectMake(10, 20, PW-36, 26), 1, 30, g_avoidPlayerRange);
        [_sliderAvoidPlayerRange addTarget:self action:@selector(sliderAvoidPlayerRangeChanged:) forControlEvents:UIControlEventValueChanged];
        [rs1 addSubview:_lblAvoidPlayerRange]; [rs1 addSubview:_sliderAvoidPlayerRange]; [_subPvpView addSubview:rs1];

        // 3. Auto Quit Near Player Toggle
        CGFloat y3 = y2 + 52 + 8;
        UIView *r2 = MakeRow(CGRectMake(8, y3, PW-16, ROW));
        UILabel *l2 = MakeLabel(@"Tự thoát khi có người gần", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor colorWithRed:1.0 green:0.45 blue:0.45 alpha:1.0]);
        _swAutoQuitPlayer = MakeSwitch(PW-16-56, 7, g_autoQuitNearPlayer);
        _swAutoQuitPlayer.onTintColor = [UIColor colorWithRed:0.95 green:0.25 blue:0.25 alpha:1.0];
        [_swAutoQuitPlayer addTarget:self action:@selector(swAutoQuitPlayerChanged:) forControlEvents:UIControlEventValueChanged];
        [r2 addSubview:l2]; [r2 addSubview:_swAutoQuitPlayer]; [_subPvpView addSubview:r2];

        // 4. Auto Quit Range Slider
        CGFloat y4 = y3 + ROW + 6;
        UIView *rs2 = MakeRow(CGRectMake(8, y4, PW-16, 52));
        _lblAutoQuitPlayerRange = MakeLabel([NSString stringWithFormat:@"Khoảng cách tự thoát: %.0fm", g_autoQuitPlayerRange],
                                             CGRectMake(10, 4, PW-36, 14), 10, [UIColor colorWithRed:1.0 green:0.45 blue:0.45 alpha:1.0]);
        _sliderAutoQuitPlayerRange = MakeSlider(CGRectMake(10, 20, PW-36, 26), 1, 30, g_autoQuitPlayerRange);
        _sliderAutoQuitPlayerRange.minimumTrackTintColor = [UIColor colorWithRed:0.95 green:0.25 blue:0.25 alpha:1.0];
        [_sliderAutoQuitPlayerRange addTarget:self action:@selector(sliderAutoQuitPlayerRangeChanged:) forControlEvents:UIControlEventValueChanged];
        [rs2 addSubview:_lblAutoQuitPlayerRange]; [rs2 addSubview:_sliderAutoQuitPlayerRange]; [_subPvpView addSubview:rs2];

        // 5. Help notice
        CGFloat y5 = y4 + 52 + 8;
        UIView *rNote = MakeRow(CGRectMake(8, y5, PW-16, 60));
        rNote.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.14 alpha:0.80];
        UILabel *lNote = MakeLabel(@"🛡️ Chế độ bảo vệ cắm farm:\nTránh va chạm PK và tự thoát game an toàn tức thì khi có người chơi tiếp cận.", CGRectMake(10, 6, PW-36, 48), 10.0, [UIColor colorWithWhite:0.7 alpha:1.0]);
        lNote.numberOfLines = 0;
        [rNote addSubview:lNote]; [_subPvpView addSubview:rNote];

        svPvp.contentSize = CGSizeMake(PW, y5 + 60 + 16);
    }
    [_autoPageView addSubview:_subPvpView];

    // ---- Sub: HP/SỐNG ----
    UIScrollView *svHp = [[UIScrollView alloc] initWithFrame:CGRectMake(0, subY, PW, subH)];
    svHp.showsVerticalScrollIndicator = YES;
    svHp.alwaysBounceVertical = YES;
    _subHpView = svHp;
    _subHpView.hidden = YES;
    {
        // Auto HP
        UIView *r1 = MakeRow(CGRectMake(8, 6, PW-16, ROW));
        UILabel *l1 = MakeLabel(@"Tự dùng bình HP", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAutoHp = MakeSwitch(PW-16-56, 7, g_autoHp);
        [_swAutoHp addTarget:self action:@selector(swHpChanged:) forControlEvents:UIControlEventValueChanged];
        [r1 addSubview:l1]; [r1 addSubview:_swAutoHp]; [_subHpView addSubview:r1];

        UIView *rs1 = MakeRow(CGRectMake(8, ROW+14, PW-16, 52));
        _lblHpPercent = MakeLabel([NSString stringWithFormat:@"Dùng khi HP < %.0f%%", g_autoHpPercent*100],
                                   CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderHpPercent = MakeSlider(CGRectMake(10, 20, PW-36, 26), 0.1f, 0.9f, g_autoHpPercent);
        [_sliderHpPercent addTarget:self action:@selector(sliderHpChanged:) forControlEvents:UIControlEventValueChanged];
        [rs1 addSubview:_lblHpPercent]; [rs1 addSubview:_sliderHpPercent]; [_subHpView addSubview:rs1];

        // Auto Revive
        CGFloat y2 = ROW + 14 + 52 + 8;
        UIView *r2 = MakeRow(CGRectMake(8, y2, PW-16, ROW));
        UILabel *l2 = MakeLabel(@"Tự động hồi sinh", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAutoRevive = MakeSwitch(PW-16-56, 7, g_autoRevive);
        [_swAutoRevive addTarget:self action:@selector(swReviveChanged:) forControlEvents:UIControlEventValueChanged];
        [r2 addSubview:l2]; [r2 addSubview:_swAutoRevive]; [_subHpView addSubview:r2];

        // Return to death position
        CGFloat y3 = y2 + ROW + 8;
        UIView *r3 = MakeRow(CGRectMake(8, y3, PW-16, ROW));
        UILabel *l3 = MakeLabel(@"Trở lại vị trí bị hạ", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        UISwitch *swReturn = MakeSwitch(PW-16-56, 7, g_returnToDeathPos);
        [swReturn addTarget:self action:@selector(swReturnChanged:) forControlEvents:UIControlEventValueChanged];
        [r3 addSubview:l3]; [r3 addSubview:swReturn]; [_subHpView addSubview:r3];
        
        svHp.contentSize = CGSizeMake(PW, y3 + ROW + 16);
    }
    [_autoPageView addSubview:_subHpView];

    // ---- Sub: TRANG BỊ ----
    UIScrollView *svDo = [[UIScrollView alloc] initWithFrame:CGRectMake(0, subY, PW, subH)];
    svDo.showsVerticalScrollIndicator = YES;
    svDo.alwaysBounceVertical = YES;
    _subDoView = svDo;
    _subDoView.hidden = YES;
    {
        UIView *r1 = MakeRow(CGRectMake(8, 6, PW-16, ROW));
        UILabel *l1 = MakeLabel(@"Tự dùng/thay trang bị tốt hơn", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAutoEquip = MakeSwitch(PW-16-56, 7, g_autoEquip);
        [_swAutoEquip addTarget:self action:@selector(swEquipChanged:) forControlEvents:UIControlEventValueChanged];
        [r1 addSubview:l1]; [r1 addSubview:_swAutoEquip]; [_subDoView addSubview:r1];

        UIView *r2 = MakeRow(CGRectMake(8, ROW+14, PW-16, 52));
        UILabel *lq = MakeLabel(@"Ngưỡng phẩm chất trang bị (>=):", CGRectMake(10, 4, PW-36, 16), 10, CLR_GREEN);
        _segEquipQuality = [[UISegmentedControl alloc] initWithItems:@[@"Thường", @"Hiếm", @"Tím", @"Cam"]];
        _segEquipQuality.frame = CGRectMake(10, 22, PW-36, 26);
        _segEquipQuality.selectedSegmentIndex = g_autoEquipQuality;
        _segEquipQuality.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:0.80];
        [_segEquipQuality setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:10]} forState:UIControlStateNormal];
        [_segEquipQuality setTitleTextAttributes:@{NSForegroundColorAttributeName:CLR_GREEN, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]} forState:UIControlStateSelected];
        [_segEquipQuality addTarget:self action:@selector(segEquipChanged:) forControlEvents:UIControlEventValueChanged];
        [r2 addSubview:lq]; [r2 addSubview:_segEquipQuality]; [_subDoView addSubview:r2];

        // Auto Sell Key row
        CGFloat yKey = ROW + 14 + 52 + 6;
        UIView *rKey = MakeRow(CGRectMake(8, yKey, PW-16, ROW));
        UILabel *lKey = MakeLabel(@"Tự động bán chìa khoá khi đào", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAutoSellKey = MakeSwitch(PW-16-56, 7, g_autoSellKey);
        [_swAutoSellKey addTarget:self action:@selector(swAutoSellKeyChanged:) forControlEvents:UIControlEventValueChanged];
        [rKey addSubview:lKey]; [rKey addSubview:_swAutoSellKey]; [_subDoView addSubview:rKey];

        // Auto Sell Ingredient row
        CGFloat y3 = yKey + ROW + 6;
        UIView *r3 = MakeRow(CGRectMake(8, y3, PW-16, ROW));
        UILabel *l3 = MakeLabel(@"Tự động bán nguyên liệu trong túi", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAutoSellIngredient = MakeSwitch(PW-16-56, 7, g_autoSellIngredient);
        [_swAutoSellIngredient addTarget:self action:@selector(swAutoSellIngredientChanged:) forControlEvents:UIControlEventValueChanged];
        [r3 addSubview:l3]; [r3 addSubview:_swAutoSellIngredient]; [_subDoView addSubview:r3];

        CGFloat y4 = y3 + ROW + 6;
        UIView *r4 = MakeRow(CGRectMake(8, y4, PW-16, 52));
        UILabel *lsi = MakeLabel(@"Bán nguyên liệu phẩm chất (<=):", CGRectMake(10, 4, PW-36, 16), 10, CLR_GREEN);
        _segSellIngredientQuality = [[UISegmentedControl alloc] initWithItems:@[@"Thường", @"Hiếm", @"Tím", @"Cam"]];
        _segSellIngredientQuality.frame = CGRectMake(10, 22, PW-36, 26);
        _segSellIngredientQuality.selectedSegmentIndex = g_autoSellIngredientQuality;
        _segSellIngredientQuality.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:0.80];
        [_segSellIngredientQuality setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:10]} forState:UIControlStateNormal];
        [_segSellIngredientQuality setTitleTextAttributes:@{NSForegroundColorAttributeName:CLR_GREEN, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]} forState:UIControlStateSelected];
        [_segSellIngredientQuality addTarget:self action:@selector(segSellIngredientQualityChanged:) forControlEvents:UIControlEventValueChanged];
        [r4 addSubview:lsi]; [r4 addSubview:_segSellIngredientQuality]; [_subDoView addSubview:r4];

        // Recipe Stone Merge row
        CGFloat yRec = y4 + 52 + 6;
        UIView *rRec = MakeRow(CGRectMake(8, yRec, PW-16, ROW));
        UILabel *lRec = MakeLabel(@"Ghép đá theo công thức (Web)", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor colorWithRed:0.20 green:0.95 blue:0.55 alpha:1.0]);
        _swRecipeMerge = MakeSwitch(PW-16-56, 7, g_recipeMergeEnabled);
        [_swRecipeMerge addTarget:self action:@selector(swRecipeMergeChanged:) forControlEvents:UIControlEventValueChanged];
        [rRec addSubview:lRec]; [rRec addSubview:_swRecipeMerge]; [_subDoView addSubview:rRec];

        // Recipe Input & Info Row
        CGFloat yRecBtn = yRec + ROW + 6;
        UIView *rRecBtn = MakeRow(CGRectMake(8, yRecBtn, PW-16, 56));
        _btnRecipeInput = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnRecipeInput.frame = CGRectMake(10, 7, 130, 24);
        _btnRecipeInput.backgroundColor = [UIColor colorWithRed:0.10 green:0.12 blue:0.22 alpha:0.90];
        _btnRecipeInput.layer.cornerRadius = 4.0f;
        _btnRecipeInput.layer.borderWidth = 1.0f;
        _btnRecipeInput.layer.borderColor = CLR_GREEN.CGColor;
        _btnRecipeInput.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0];
        [_btnRecipeInput setTitle:@"📋 Nhập công thức" forState:UIControlStateNormal];
        [_btnRecipeInput setTitleColor:CLR_GREEN forState:UIControlStateNormal];
        [_btnRecipeInput addTarget:self action:@selector(btnRecipeInputPressed:) forControlEvents:UIControlEventTouchUpInside];

        UIButton *btnClearRec = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClearRec.frame = CGRectMake(10 + 130 + 8, 7, 50, 24);
        btnClearRec.backgroundColor = [UIColor colorWithRed:0.20 green:0.10 blue:0.10 alpha:0.80];
        btnClearRec.layer.cornerRadius = 4.0f;
        btnClearRec.layer.borderWidth = 0.8f;
        btnClearRec.layer.borderColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:0.6].CGColor;
        btnClearRec.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10.5];
        [btnClearRec setTitle:@"Xóa" forState:UIControlStateNormal];
        [btnClearRec setTitleColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
        [btnClearRec addTarget:self action:@selector(btnClearRecipePressed:) forControlEvents:UIControlEventTouchUpInside];

        _lblRecipeInfo = [[UILabel alloc] initWithFrame:CGRectMake(10, 33, PW-36, 18)];
        _lblRecipeInfo.font = [UIFont fontWithName:@"HelveticaNeue" size:10.5];
        [self updateRecipeInfoLabel];
        [rRecBtn addSubview:_btnRecipeInput]; [rRecBtn addSubview:btnClearRec]; [rRecBtn addSubview:_lblRecipeInfo]; [_subDoView addSubview:rRecBtn];

        // Go to nearest campfire row
        CGFloat yGoFire = yRecBtn + 56 + 6;
        UIView *rGoFire = MakeRow(CGRectMake(8, yGoFire, PW-16, ROW));
        UILabel *lGoFire = MakeLabel(@"Tìm trại lửa gần nhất để ghép", CGRectMake(10, 7, PW-16-66, 30), 12.0, [UIColor whiteColor]);
        _swRecipeMergeGoToFire = MakeSwitch(PW-16-56, 7, g_recipeMergeGoToFire);
        [_swRecipeMergeGoToFire addTarget:self action:@selector(swRecipeMergeGoToFireChanged:) forControlEvents:UIControlEventValueChanged];
        [rGoFire addSubview:lGoFire]; [rGoFire addSubview:_swRecipeMergeGoToFire]; [_subDoView addSubview:rGoFire];

        // Auto Merge Ingredient row (3 stones)
        CGFloat y5 = yGoFire + ROW + 6;
        UIView *r5 = MakeRow(CGRectMake(8, y5, PW-16, ROW));
        UILabel *l5 = MakeLabel(@"Ghép 3 viên cùng loại (mặc định)", CGRectMake(10, 7, PW-16-66, 30), 12.0, [UIColor whiteColor]);
        _swAutoMergeIngredient = MakeSwitch(PW-16-56, 7, g_autoMergeIngredient);
        [_swAutoMergeIngredient addTarget:self action:@selector(swAutoMergeIngredientChanged:) forControlEvents:UIControlEventValueChanged];
        [r5 addSubview:l5]; [r5 addSubview:_swAutoMergeIngredient]; [_subDoView addSubview:r5];

        CGFloat y6 = y5 + ROW + 6;
        UIView *r6 = MakeRow(CGRectMake(8, y6, PW-16, 52));
        UILabel *lmi = MakeLabel(@"Ghép đá đến phẩm chất (<=):", CGRectMake(10, 4, PW-36, 16), 10, CLR_GREEN);
        _segMergeIngredientQuality = [[UISegmentedControl alloc] initWithItems:@[@"Thường", @"Hiếm", @"Tím", @"Cam"]];
        _segMergeIngredientQuality.frame = CGRectMake(10, 22, PW-36, 26);
        _segMergeIngredientQuality.selectedSegmentIndex = g_autoMergeIngredientQuality;
        _segMergeIngredientQuality.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.15 alpha:0.80];
        [_segMergeIngredientQuality setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:10]} forState:UIControlStateNormal];
        [_segMergeIngredientQuality setTitleTextAttributes:@{NSForegroundColorAttributeName:CLR_GREEN, NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]} forState:UIControlStateSelected];
        [_segMergeIngredientQuality addTarget:self action:@selector(segMergeIngredientQualityChanged:) forControlEvents:UIControlEventValueChanged];
        [r6 addSubview:lmi]; [r6 addSubview:_segMergeIngredientQuality]; [_subDoView addSubview:r6];
        
        svDo.contentSize = CGSizeMake(PW, y6 + 52 + 20);
    }
    [_autoPageView addSubview:_subDoView];

    [_panel addSubview:_autoPageView];

    // ---- SETTINGS PAGE ----
    UIScrollView *svSettings = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 47, PW, PH - 47 - 24)];
    svSettings.showsVerticalScrollIndicator = YES;
    svSettings.alwaysBounceVertical = YES;
    _settingsPageView = svSettings;
    _settingsPageView.backgroundColor = [UIColor clearColor];
    _settingsPageView.hidden = YES;
    {
        // Master Switch row
        UIView *r0 = MakeRow(CGRectMake(8, 8, PW-16, ROW));
        UILabel *l0 = MakeLabel(@"Bật hệ thống Auto", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        UISwitch *swMaster = MakeSwitch(PW-16-56, 7, g_menuMasterSwitch);
        [swMaster addTarget:self action:@selector(swMasterChanged:) forControlEvents:UIControlEventValueChanged];
        [r0 addSubview:l0]; [r0 addSubview:swMaster]; [_settingsPageView addSubview:r0];

        // Radar circle HUD row
        UIView *rRadar = MakeRow(CGRectMake(8, ROW+18, PW-16, ROW));
        UILabel *lRadar = MakeLabel(@"Vẽ vòng tròn phạm vi (Radar)", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swShowRangeCircles = MakeSwitch(PW-16-56, 7, g_showRangeCircles);
        [_swShowRangeCircles addTarget:self action:@selector(swShowRangeCirclesChanged:) forControlEvents:UIControlEventValueChanged];
        [rRadar addSubview:lRadar]; [rRadar addSubview:_swShowRangeCircles]; [_settingsPageView addSubview:rRadar];

        UIView *r1 = MakeRow(CGRectMake(8, ROW*2+28, PW-16, ROW));
        UILabel *l1 = MakeLabel(@"Camera Zoom Rộng", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swZoom = MakeSwitch(PW-16-56, 7, g_cameraZoomOn);
        [_swZoom addTarget:self action:@selector(swZoomChanged:) forControlEvents:UIControlEventValueChanged];
        [r1 addSubview:l1]; [r1 addSubview:_swZoom]; [_settingsPageView addSubview:r1];

        UIView *r2 = MakeRow(CGRectMake(8, ROW*3+38, PW-16, 52));
        _lblZoomValue = MakeLabel([NSString stringWithFormat:@"Độ rộng tầm nhìn: %.1f", g_cameraZoomValue],
                                   CGRectMake(10, 4, PW-36, 14), 10, CLR_GREEN);
        _sliderZoom = MakeSlider(CGRectMake(10, 20, PW-36, 26), 5, 25, g_cameraZoomValue);
        [_sliderZoom addTarget:self action:@selector(sliderZoomChanged:) forControlEvents:UIControlEventValueChanged];
        [r2 addSubview:_lblZoomValue]; [r2 addSubview:_sliderZoom]; [_settingsPageView addSubview:r2];

        UIView *rfps = MakeRow(CGRectMake(8, ROW*3+98, PW-16, ROW));
        UILabel *lfps = MakeLabel(@"Hiển thị FPS màn hình", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swShowFps = MakeSwitch(PW-16-56, 7, g_showFps);
        [_swShowFps addTarget:self action:@selector(swFpsChanged:) forControlEvents:UIControlEventValueChanged];
        [rfps addSubview:lfps]; [rfps addSubview:_swShowFps]; [_settingsPageView addSubview:rfps];
        
        UIView *rads = MakeRow(CGRectMake(8, ROW*4+108, PW-16, ROW));
        UILabel *lads = MakeLabel(@"Tự động nhận thưởng QC", CGRectMake(10, 7, PW-16-66, 30), 12.5, [UIColor whiteColor]);
        _swAutoWatchAds = MakeSwitch(PW-16-56, 7, g_autoWatchAds);
        [_swAutoWatchAds addTarget:self action:@selector(swAutoWatchAdsChanged:) forControlEvents:UIControlEventValueChanged];
        [rads addSubview:lads]; [rads addSubview:_swAutoWatchAds]; [_settingsPageView addSubview:rads];
        
        svSettings.contentSize = CGSizeMake(PW, ROW*4 + 108 + ROW + 20);
    }
    [_panel addSubview:_settingsPageView];

    // ---- CONTACT PAGE ----
    _contactPageView = [[UIView alloc] initWithFrame:CGRectMake(0, 47, PW, PH - 47 - 24)];
    _contactPageView.backgroundColor = [UIColor clearColor];
    _contactPageView.hidden = YES;
    {
        CGFloat cw = PW - 24;
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(12, 8, cw, 220)];
        card.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.20 alpha:0.40];
        card.layer.cornerRadius = 8.0f;
        card.layer.borderWidth = 1.0f;
        card.layer.borderColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.30].CGColor;
        
        UILabel *titleLabel = MakeLabel(@"👤 Tác giả: Shiuliuliu", CGRectMake(12, 12, cw - 24, 20), 13.0, [UIColor colorWithRed:0.20 green:0.95 blue:0.55 alpha:1.0]);
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
        [card addSubview:titleLabel];
        
        // Facebook Row
        UILabel *lblFb = MakeLabel(@"📘 Facebook: Shinliumod", CGRectMake(12, 45, 155, 26), 11.5, [UIColor whiteColor]);
        UIButton *btnFb = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFb.frame = CGRectMake(cw - 12 - 75, 44, 75, 26);
        btnFb.backgroundColor = [UIColor colorWithRed:0.09 green:0.30 blue:0.60 alpha:0.90];
        btnFb.layer.cornerRadius = 4.0f;
        [btnFb setTitle:@"Liên hệ" forState:UIControlStateNormal];
        btnFb.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.5];
        [btnFb addTarget:self action:@selector(openFacebook:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:lblFb]; [card addSubview:btnFb];
        
        // Telegram Row
        UILabel *lblTg = MakeLabel(@"✈️ Telegram: @shiuliuliu", CGRectMake(12, 80, 155, 26), 11.5, [UIColor whiteColor]);
        UIButton *btnTg = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTg.frame = CGRectMake(cw - 12 - 75, 79, 75, 26);
        btnTg.backgroundColor = [UIColor colorWithRed:0.12 green:0.53 blue:0.80 alpha:0.90];
        btnTg.layer.cornerRadius = 4.0f;
        [btnTg setTitle:@"Liên hệ" forState:UIControlStateNormal];
        btnTg.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.5];
        [btnTg addTarget:self action:@selector(openTelegram:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:lblTg]; [card addSubview:btnTg];
        
        // Youtube Row
        UILabel *lblYt = MakeLabel(@"🔴 Youtube: Shiuliuliu Gamer", CGRectMake(12, 115, 155, 26), 11.5, [UIColor whiteColor]);
        UIButton *btnYt = [UIButton buttonWithType:UIButtonTypeCustom];
        btnYt.frame = CGRectMake(cw - 12 - 75, 114, 75, 26);
        btnYt.backgroundColor = [UIColor colorWithRed:0.80 green:0.15 blue:0.15 alpha:0.90];
        btnYt.layer.cornerRadius = 4.0f;
        [btnYt setTitle:@"Truy cập" forState:UIControlStateNormal];
        btnYt.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.5];
        [btnYt addTarget:self action:@selector(openYoutube:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:lblYt]; [card addSubview:btnYt];
        
        // Group Telegram Row
        UILabel *lblGroupTg = MakeLabel(@"💬 Group Telegram", CGRectMake(12, 150, 155, 26), 11.5, [UIColor whiteColor]);
        UIButton *btnGroupTg = [UIButton buttonWithType:UIButtonTypeCustom];
        btnGroupTg.frame = CGRectMake(cw - 12 - 75, 149, 75, 26);
        btnGroupTg.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.8 alpha:0.90];
        btnGroupTg.layer.cornerRadius = 4.0f;
        [btnGroupTg setTitle:@"Tham gia" forState:UIControlStateNormal];
        btnGroupTg.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.5];
        [btnGroupTg addTarget:self action:@selector(openGroupTelegram:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:lblGroupTg]; [card addSubview:btnGroupTg];
        
        // Version info
        UILabel *versionLabel = MakeLabel(@"Phiên bản Tweak: v4.1.6 Premium", CGRectMake(12, 188, cw - 24, 18), 10.5, [UIColor colorWithWhite:0.7 alpha:1.0]);
        versionLabel.textAlignment = NSTextAlignmentCenter;
        [card addSubview:versionLabel];
        
        [_contactPageView addSubview:card];

        // Copyright label
        UILabel *copyLabel = MakeLabel(@"Copyright © 2026 Shinliu. All rights reserved.", CGRectMake(12, PH - 47 - 24 - 26, PW-24, 20), 9.5, [UIColor colorWithWhite:0.5 alpha:1.0]);
        copyLabel.textAlignment = NSTextAlignmentCenter;
        [_contactPageView addSubview:copyLabel];
    }
    [_panel addSubview:_contactPageView];

    // Status bar
    _lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(8, PH-22, PW-16, 18)];
    _lblStatus.text = @"Trạng thái: Chờ kích hoạt";
    _lblStatus.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
    _lblStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:9.5];
    _lblStatus.textAlignment = NSTextAlignmentCenter;
    [_panel addSubview:_lblStatus];

    // Initialize ESP distance label
    _lblEspText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 75, 18)];
    _lblEspText.textColor = CLR_GREEN;
    _lblEspText.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65];
    _lblEspText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.5];
    _lblEspText.textAlignment = NSTextAlignmentCenter;
    _lblEspText.layer.cornerRadius = 4.0f;
    _lblEspText.layer.masksToBounds = YES;
    _lblEspText.hidden = YES;
    [self addSubview:_lblEspText];

    // Floating FPS badge on screen (draggable)
    _lblFpsBadge = [[UILabel alloc] initWithFrame:CGRectMake(10, 32, 60, 20)];
    _lblFpsBadge.text = @"-- FPS";
    _lblFpsBadge.textColor = CLR_GREEN;
    _lblFpsBadge.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.09 alpha:0.85];
    _lblFpsBadge.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.5];
    _lblFpsBadge.textAlignment = NSTextAlignmentCenter;
    _lblFpsBadge.layer.cornerRadius = 4.0f;
    _lblFpsBadge.layer.masksToBounds = YES;
    _lblFpsBadge.layer.borderWidth = 1.0f;
    _lblFpsBadge.layer.borderColor = CLR_GREEN.CGColor;
    _lblFpsBadge.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panFps = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
    [_lblFpsBadge addGestureRecognizer:panFps];
    [self addSubview:_lblFpsBadge];

    [self addSubview:_panel];
}

// =============================================
// 60FPS Movement Loop
// =============================================
- (void)updateESPLine {
    if (!s_attached) return;

    // Calculate & update FPS live on screen
    static double s_lastFpsTime = 0;
    static int s_frameCount = 0;
    static float s_currentFps = 60.0f;
    double nowFpsTime = [[NSProcessInfo processInfo] systemUptime];
    s_frameCount++;
    if (nowFpsTime - s_lastFpsTime >= 0.5) {
        s_currentFps = (float)s_frameCount / (float)(nowFpsTime - s_lastFpsTime);
        s_frameCount = 0;
        s_lastFpsTime = nowFpsTime;
        if (g_showFps && _lblFpsBadge) {
            _lblFpsBadge.hidden = NO;
            _lblFpsBadge.text = [NSString stringWithFormat:@"%.0f FPS", s_currentFps];
            if (s_currentFps >= 50.0f) {
                _lblFpsBadge.textColor = CLR_GREEN;
                _lblFpsBadge.layer.borderColor = [UIColor colorWithRed:0.20 green:0.95 blue:0.55 alpha:0.6].CGColor;
            } else if (s_currentFps >= 30.0f) {
                _lblFpsBadge.textColor = [UIColor colorWithRed:1.0 green:0.80 blue:0.20 alpha:1.0];
                _lblFpsBadge.layer.borderColor = [UIColor colorWithRed:1.0 green:0.80 blue:0.20 alpha:0.6].CGColor;
            } else {
                _lblFpsBadge.textColor = [UIColor colorWithRed:1.0 green:0.35 blue:0.35 alpha:1.0];
                _lblFpsBadge.layer.borderColor = [UIColor colorWithRed:1.0 green:0.35 blue:0.35 alpha:0.6].CGColor;
            }
        }
    }
    if (!g_showFps && _lblFpsBadge) {
        _lblFpsBadge.hidden = YES;
    }

    if (!g_menuMasterSwitch) {
        void* playerMovement = GetLocalPlayerMovement();
        if (playerMovement) {
            static void* setExternalInputMI = nullptr;
            static void* pmKlass = nullptr;
            if (!pmKlass) pmKlass = ScanFindClass("", "AuthorativePlayerMovement");
            if (pmKlass && !setExternalInputMI) setExternalInputMI = FindMethodInHierarchy(pmKlass, "SetExternalInput", 1);
            if (setExternalInputMI) {
                Vector2 zero = { 0.0f, 0.0f };
                void* params[1] = { &zero };
                SafeInvoke(setExternalInputMI, playerMovement, params);
            }
        }
        _lblEspText.hidden = YES;
        if (g_window) [g_window setStatusText:@"Hệ thống Auto: Tắt"];
        return;
    }

    void* playerMovement = GetLocalPlayerMovement();
    if (!playerMovement) return;
    void* playerObj = *(void**)((uint8_t*)playerMovement + 0xa8);
    if (!playerObj) return;

    // Get real-time position
    static void* getTransformMI = nullptr, *getPositionMI = nullptr;
    static void* componentKlass = nullptr, *transformKlass = nullptr;
    if (!componentKlass) componentKlass = ScanFindClass("UnityEngine", "Component");
    if (componentKlass && !getTransformMI) getTransformMI = FindMethodInHierarchy(componentKlass, "get_transform", 0);
    if (!transformKlass) transformKlass = ScanFindClass("UnityEngine", "Transform");
    if (transformKlass && !getPositionMI) getPositionMI = FindMethodInHierarchy(transformKlass, "get_position", 0);

    Vector3 playerPos = g_cachedPlayerPos;
    if (getTransformMI && getPositionMI) {
        void* playerTrans = SafeInvoke(getTransformMI, playerObj, nullptr);
        if (playerTrans) {
            void* boxed = SafeInvoke(getPositionMI, playerTrans, nullptr);
            if (boxed) playerPos = *(Vector3*)((uint8_t*)boxed + 16);
        }
    }

    float moveX = 0.0f, moveY = 0.0f;
    bool shouldMove = false;
    bool reachedTarget = false;

    bool isCampfireNav = (g_isGoingToFire || g_isAtFireForRecipe || g_isReturningToFarm);

    if (g_hasCachedTarget && (g_autoDig || isCampfireNav || (g_autoAttackMobs && g_cachedTargetIsMob))) {
        float dirX = g_cachedTargetPos.x - playerPos.x;
        float dirY = g_cachedTargetPos.y - playerPos.y;
        float dist = sqrtf(dirX*dirX + dirY*dirY);
        float boxDist = fmaxf(fabsf(dirX), fabsf(dirY));
        float checkDist = (g_cachedTargetIsMob || isCampfireNav) ? dist : boxDist;

        // Hysteresis logic: only reset if target moved to a distinct tile (> 0.6m)
        float targetMoved = sqrtf(powf(g_cachedTargetPos.x - g_lastTargetPos.x, 2) + powf(g_cachedTargetPos.y - g_lastTargetPos.y, 2));
        if (targetMoved > 0.6f) {
            g_isAtTarget = false;
            g_lastTargetPos = g_cachedTargetPos;
        }

        float stopDist = g_cachedTargetIsMob ? 1.0f : (g_isGoingToFire ? 3.5f : (g_isReturningToFarm ? 1.0f : (isCampfireNav ? 3.5f : fmaxf(g_digStopDist, 0.40f))));

        if (g_isAtTarget) {
            float leaveDist = g_cachedTargetIsMob ? 1.4f : (g_isGoingToFire ? 4.2f : (g_isReturningToFarm ? 1.4f : (isCampfireNav ? 4.2f : 1.10f)));
            if (checkDist > leaveDist && !g_isAtFireForRecipe) {
                g_isAtTarget = false;
            }
        } else {
            if (checkDist <= stopDist || g_isAtFireForRecipe) {
                g_isAtTarget = true;
                g_targetStartTime = [[NSProcessInfo processInfo] systemUptime];
            }
        }

        if (!g_isAtTarget && !g_isAtFireForRecipe) {
            moveX = dirX;
            moveY = dirY;
            shouldMove = true;
        } else {
            reachedTarget = true;
        }
    }

    // Real-time Player Avoidance & Auto-Quit at 60 FPS
    float playerAvoidX = 0.0f, playerAvoidY = 0.0f;
    bool hasPlayerAvoid = false;
    if (g_avoidPlayers || g_autoQuitNearPlayer) {
        static void* pbKlassForScan = nullptr;
        if (!pbKlassForScan) pbKlassForScan = ScanFindClass("", "PlayerBehavior");
        if (pbKlassForScan) {
            int32_t pCount = 0;
            void* pArr = Il2cppFindObjects(pbKlassForScan, &pCount);
            if (pArr && pCount > 0) {
                for (int pi = 0; pi < pCount; pi++) {
                    void* otherP = GetArrElem(pArr, pi);
                    if (!otherP || otherP == playerObj || !IsValidUnityObj(otherP)) continue;
                    void* pHealth = *(void**)((uint8_t*)otherP + 0x1d0);
                    if (pHealth && *(int32_t*)((uint8_t*)pHealth + 0x68) <= 0) continue;
                    void* pTr = SafeInvoke(getTransformMI, otherP, nullptr);
                    if (!pTr) continue;
                    void* pBx = SafeInvoke(getPositionMI, pTr, nullptr);
                    if (!pBx) continue;
                    Vector3 otherPos = *(Vector3*)((uint8_t*)pBx + 16);
                    float pdx = playerPos.x - otherPos.x;
                    float pdy = playerPos.y - otherPos.y;
                    float pdist = sqrtf(pdx * pdx + pdy * pdy);
                    
                    // 1. Auto quit when other player in range (instant 60 FPS safety)
                    if (g_autoQuitNearPlayer && pdist <= g_autoQuitPlayerRange && pdist > 0.05f) {
                        NSLog(@"[THTweak] WARNING: Other player detected at distance %.2fm! Auto-quitting game to protect account...", pdist);
                        exit(0);
                        return;
                    }
                    
                    // 2. Repulsive avoidance force from other players
                    if (g_avoidPlayers && pdist < g_avoidPlayerRange) {
                        if (pdist < 0.1f) pdist = 0.1f;
                        float force = (g_avoidPlayerRange - pdist) * 3.0f;
                        playerAvoidX += (pdx / pdist) * force;
                        playerAvoidY += (pdy / pdist) * force;
                        hasPlayerAvoid = true;
                    }
                }
            }
        }
    }

    // Apply avoid forces (Mobs + Real-time 60FPS Players)
    if (hasPlayerAvoid) {
        moveX += playerAvoidX;
        moveY += playerAvoidY;
        shouldMove = true;
        reachedTarget = false;
    }
    if (g_autoAvoidMobs && s_hasAvoidForces) {
        moveX += s_avoidX;
        moveY += s_avoidY;
        shouldMove = true;
        reachedTarget = false;
    }

    // If reached target and no avoid forces
    if (reachedTarget && !shouldMove) {
        if (g_isReturningToFarm) {
            if (g_window) [g_window setStatusText:@"Đã về bãi farm - Tiếp tục đào..."];
        } else if (isCampfireNav) {
            if (g_window) [g_window setStatusText:@"Đã đến trại lửa - Đang ghép đá..."];
        } else {
            if (g_window) [g_window setStatusText:@"Đã đến đích - Đang đào..."];
        }
        
        // Hide ESP label when reached
        _lblEspText.hidden = YES;
    }

    // Normalize final direction and apply speed scaling
    if (shouldMove) {
        float len = sqrtf(moveX*moveX + moveY*moveY);
        if (len > 0.01f) {
            moveX /= len;
            moveY /= len;

            // Apply speed scaling near tile AFTER normalization to ensure it is not wiped out
            if (g_hasCachedTarget && !g_cachedTargetIsMob && !isCampfireNav) {
                float dx = g_cachedTargetPos.x - playerPos.x;
                float dy = g_cachedTargetPos.y - playerPos.y;
                float boxDist = fmaxf(fabsf(dx), fabsf(dy));
                
                // Get player speed stat to dynamically adjust deceleration
                float playerSpeed = 5.0f;
                if (playerObj) {
                    playerSpeed = *(float*)((uint8_t*)playerObj + 0x2c4);
                    if (playerSpeed < 0.5f) playerSpeed = 5.0f;
                }
                
                // Estimate frame delta time
                static double lastFrameTime = 0;
                double now = [[NSProcessInfo processInfo] systemUptime];
                float dt = (lastFrameTime > 0) ? (float)(now - lastFrameTime) : 0.0166f;
                lastFrameTime = now;
                if (dt <= 0.0f || dt > 0.1f) dt = 0.0166f;
                
                // Start decelerating zone: scaled by player speed and g_speedSensitivity
                float decelStart = fmaxf(g_digStopDist + 0.40f, playerSpeed * 0.20f * g_speedSensitivity);
                
                if (boxDist < decelStart) {
                    float targetStop = g_digStopDist;
                    // Max distance we can move this frame without overshooting targetStop
                    float maxMoveThisFrame = boxDist - (targetStop * 0.70f);
                    if (maxMoveThisFrame < 0.01f) maxMoveThisFrame = 0.01f;
                    
                    // The speed factor required to cover maxMoveThisFrame in dt:
                    float calculatedFactor = maxMoveThisFrame / (playerSpeed * dt);
                    
                    // Decelerate smoothly based on linear interpolation from 1.0 down to calculatedFactor
                    float t = (boxDist - targetStop) / (decelStart - targetStop);
                    if (t < 0.0f) t = 0.0f;
                    if (t > 1.0f) t = 1.0f;
                    
                    float minFactor = fminf(0.1f, calculatedFactor); // ensure we can go as low as needed
                    if (minFactor < 0.02f) minFactor = 0.02f;
                    
                    float speedFactor = minFactor + t * (1.0f - minFactor);
                    
                    // Cap it to prevent overshoot if calculatedFactor is extremely small
                    if (speedFactor > calculatedFactor) {
                        speedFactor = calculatedFactor;
                    }
                    if (speedFactor < 0.02f) speedFactor = 0.02f;
                    if (speedFactor > 1.0f) speedFactor = 1.0f;
                    
                    moveX *= speedFactor;
                    moveY *= speedFactor;
                }
            }
        }
        else { moveX = 0.0f; moveY = 0.0f; shouldMove = false; }
    }

    static bool s_wasAutoMoving = false;
    bool isAutoEnabled = g_menuMasterSwitch && (g_autoDig || isCampfireNav || g_autoAttackMobs || g_autoAvoidMobs || g_avoidPlayers);

    // If no auto functions are active, do not touch player joystick/movement inputs
    if (!isAutoEnabled) {
        if (s_wasAutoMoving) {
            HardStopJoystick(playerMovement, playerPos);
            s_wasAutoMoving = false;
        }
    } else {
        // Write to PlayerMovement and Joystick only when actively navigating
        if (shouldMove) {
            s_wasAutoMoving = true;
            if (playerMovement) {
                static void* setExternalInputMI = nullptr;
                static void* pmKlass = nullptr;
                if (!pmKlass) pmKlass = ScanFindClass("", "AuthorativePlayerMovement");
                if (pmKlass && !setExternalInputMI) setExternalInputMI = FindMethodInHierarchy(pmKlass, "SetExternalInput", 1);
                if (setExternalInputMI) {
                    Vector2 moveVec = { moveX, moveY };
                    void* params[1] = { &moveVec };
                    SafeInvoke(setExternalInputMI, playerMovement, params);
                }
            }
            void* joy = GetJoystickObject();
            if (joy) {
                static void* setJoystickValuesMI = nullptr;
                static void* joystickKlass = nullptr;
                if (!joystickKlass) joystickKlass = ScanFindClass("", "Joystick");
                if (joystickKlass && !setJoystickValuesMI)
                    setJoystickValuesMI = FindMethodInHierarchy(joystickKlass, "SetJoystickValues", 1);
                if (setJoystickValuesMI) {
                    Vector2 dir = { moveX, moveY };
                    void* params[1] = { &dir };
                    SafeInvoke(setJoystickValuesMI, joy, params);
                } else {
                    *(Vector2*)((uint8_t*)joy + 0x58) = { moveX, moveY };
                }
            }
        } else {
            if (s_wasAutoMoving) {
                HardStopJoystick(playerMovement, playerPos);
                s_wasAutoMoving = false;
            }
        }
    }

    // Status update
    if (g_window) {
        if (g_isAtFireForRecipe) {
            [g_window setStatusText:@"Đang ở trại lửa - Đang ghép đá..."];
        } else if (g_isReturningToFarm) {
            [g_window setStatusText:[NSString stringWithFormat:@"Về bãi farm | %.1fm", g_cachedClosestDist]];
        } else if (g_isGoingToFire) {
            [g_window setStatusText:[NSString stringWithFormat:@"Đến trại lửa | %.1fm", g_cachedClosestDist]];
        } else if (g_hasCachedTarget && (g_autoDig || g_autoAttackMobs)) {
            NSString *tName = g_cachedTargetIsMob ? @"Quái vật" : @"Khối đất";
            [g_window setStatusText:[NSString stringWithFormat:@"Bám: %@ | %.1fm", tName, g_cachedClosestDist]];
        } else if (g_autoDig || g_autoAttackMobs || isCampfireNav) {
            [g_window setStatusText:@"Không tìm thấy mục tiêu!"];
        } else {
            [g_window setStatusText:@"Trạng thái: Chờ kích hoạt"];
        }
    }

    // Target Tile/Mob Distance ESP Overlay (Without drawing lines)
    if (g_hasCachedTarget && (g_autoDig || isCampfireNav || (g_autoAttackMobs && g_cachedTargetIsMob))) {
        static void* get_mainMI = nullptr;
        static void* worldToScreenPointMI = nullptr;
        static void* cameraKlass = nullptr;
        if (!cameraKlass) cameraKlass = ScanFindClass("UnityEngine", "Camera");
        if (cameraKlass) {
            if (!get_mainMI) get_mainMI = FindMethodInHierarchy(cameraKlass, "get_main", 0);
            if (!worldToScreenPointMI) worldToScreenPointMI = FindMethodInHierarchy(cameraKlass, "WorldToScreenPoint", 1);
        }

        bool espUpdated = false;
        if (get_mainMI && worldToScreenPointMI) {
            double nowCamTime = [[NSProcessInfo processInfo] systemUptime];
            if (!g_cachedMainCam || !IsValidUnityObj(g_cachedMainCam) || nowCamTime - g_lastCamFetchTime > 1.0) {
                g_cachedMainCam = SafeInvoke(get_mainMI, nullptr, nullptr);
                g_lastCamFetchTime = nowCamTime;
            }
            if (IsValidUnityObj(g_cachedMainCam)) {
                Vector3 worldPos = g_cachedTargetPos;
                void* params[1] = { &worldPos };
                void* boxedScreenPos = SafeInvoke(worldToScreenPointMI, g_cachedMainCam, params);
                if (boxedScreenPos) {
                    Vector3 screenPos = *(Vector3*)((uint8_t*)boxedScreenPos + 16);
                    if (screenPos.z > 0.0f) {
                        CGFloat scale = [UIScreen mainScreen].scale;
                        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
                        CGFloat x = screenPos.x / scale;
                        CGFloat y = screenHeight - (screenPos.y / scale);

                        _lblEspText.text = [NSString stringWithFormat:@"%.1fm", g_cachedClosestDist];
                        _lblEspText.center = CGPointMake(x, y - 18); // offset slightly above the tile center
                        _lblEspText.hidden = NO;
                        espUpdated = true;
                    }
                }
            }
        }
        if (!espUpdated) {
            _lblEspText.hidden = YES;
        }
    } else {
        _lblEspText.hidden = YES;
    }

    // =============================================
    // Range Circles (Radar HUD Visualization at 60 FPS)
    // =============================================
    if (g_showRangeCircles && (playerPos.x != 0.0f || playerPos.y != 0.0f)) {
        CGPoint playerScreenPt = CGPointZero;
        if (WorldToScreen(playerPos, &playerScreenPt)) {
            // 1. Dig Range
            if (g_autoDig) {
                CGFloat r = GetScreenRadius(playerPos, g_digRangeValue);
                if (r > 2.0f && r < 2500.0f) {
                    _digRangeLayer.path = [UIBezierPath bezierPathWithArcCenter:playerScreenPt radius:r startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
                } else { _digRangeLayer.path = nil; }
            } else { _digRangeLayer.path = nil; }
            
            // 2. Lock Dig Center Range
            if (g_lockDigPos && g_hasLockedPos) {
                CGPoint lockScreenPt = CGPointZero;
                if (WorldToScreen(g_lockedDigPos, &lockScreenPt)) {
                    CGFloat r = GetScreenRadius(g_lockedDigPos, g_lockedDigRange);
                    if (r > 2.0f && r < 2500.0f) {
                        _lockDigRangeLayer.path = [UIBezierPath bezierPathWithArcCenter:lockScreenPt radius:r startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
                    } else { _lockDigRangeLayer.path = nil; }
                } else { _lockDigRangeLayer.path = nil; }
            } else { _lockDigRangeLayer.path = nil; }
            
            // 3. Attack Mobs Range
            if (g_autoAttackMobs) {
                CGFloat r = GetScreenRadius(playerPos, g_attackRangeValue);
                if (r > 2.0f && r < 2500.0f) {
                    _attackRangeLayer.path = [UIBezierPath bezierPathWithArcCenter:playerScreenPt radius:r startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
                } else { _attackRangeLayer.path = nil; }
            } else { _attackRangeLayer.path = nil; }
            
            // 4. Avoid Mobs Range
            if (g_autoAvoidMobs) {
                CGFloat r = GetScreenRadius(playerPos, g_avoidRangeValue);
                if (r > 2.0f && r < 2500.0f) {
                    _mobAvoidRangeLayer.path = [UIBezierPath bezierPathWithArcCenter:playerScreenPt radius:r startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
                } else { _mobAvoidRangeLayer.path = nil; }
            } else { _mobAvoidRangeLayer.path = nil; }
            
            // 5. Avoid Players Range
            if (g_avoidPlayers) {
                CGFloat r = GetScreenRadius(playerPos, g_avoidPlayerRange);
                if (r > 2.0f && r < 2500.0f) {
                    _playerAvoidRangeLayer.path = [UIBezierPath bezierPathWithArcCenter:playerScreenPt radius:r startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
                } else { _playerAvoidRangeLayer.path = nil; }
            } else { _playerAvoidRangeLayer.path = nil; }
            
            // 6. Auto Quit Near Player Range
            if (g_autoQuitNearPlayer) {
                CGFloat r = GetScreenRadius(playerPos, g_autoQuitPlayerRange);
                if (r > 2.0f && r < 2500.0f) {
                    _autoQuitRangeLayer.path = [UIBezierPath bezierPathWithArcCenter:playerScreenPt radius:r startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
                } else { _autoQuitRangeLayer.path = nil; }
            } else { _autoQuitRangeLayer.path = nil; }
        } else {
            _digRangeLayer.path = nil;
            _lockDigRangeLayer.path = nil;
            _attackRangeLayer.path = nil;
            _mobAvoidRangeLayer.path = nil;
            _playerAvoidRangeLayer.path = nil;
            _autoQuitRangeLayer.path = nil;
        }
    } else {
        _digRangeLayer.path = nil;
        _lockDigRangeLayer.path = nil;
        _attackRangeLayer.path = nil;
        _mobAvoidRangeLayer.path = nil;
        _playerAvoidRangeLayer.path = nil;
        _autoQuitRangeLayer.path = nil;
    }
}

- (void)setStatusText:(NSString *)text { _lblStatus.text = text; }

// =============================================
// Tab Actions
// =============================================
- (void)mainTabChanged:(UISegmentedControl *)sender {
    _autoPageView.hidden     = sender.selectedSegmentIndex != 0;
    _settingsPageView.hidden = sender.selectedSegmentIndex != 1;
    _contactPageView.hidden  = sender.selectedSegmentIndex != 2;
}
- (void)autoSubTabChanged:(UISegmentedControl *)sender {
    _subDaoView.hidden   = sender.selectedSegmentIndex != 0;
    _subQuaiView.hidden  = sender.selectedSegmentIndex != 1;
    _subPvpView.hidden   = sender.selectedSegmentIndex != 2;
    _subHpView.hidden    = sender.selectedSegmentIndex != 3;
    _subDoView.hidden    = sender.selectedSegmentIndex != 4;
}

// =============================================
// Toggle/Slider Actions
// =============================================
- (void)swDigChanged:(UISwitch *)s    { g_autoDig        = s.on; }
- (void)swLockDigPosChanged:(UISwitch *)s {
    g_lockDigPos = s.on;
    if (g_lockDigPos) {
        g_lockedDigPos = g_cachedPlayerPos;
        g_hasLockedPos = true;
    } else {
        g_hasLockedPos = false;
    }
    if (_rowLockDigRange) {
        _rowLockDigRange.hidden = !g_lockDigPos;
    }
}
- (void)sliderLockDigRangeChanged:(UISlider *)s {
    g_lockedDigRange = s.value;
    if (_lblLockDigRange) {
        _lblLockDigRange.text = [NSString stringWithFormat:@"Bán kính farm đá: %.1fm", g_lockedDigRange];
    }
}
- (void)swAvoidChanged:(UISwitch *)s  { g_autoAvoidMobs  = s.on; }
- (void)swAttackChanged:(UISwitch *)s { g_autoAttackMobs = s.on; }
- (void)swAvoidBossChanged:(UISwitch *)s { g_avoidBoss = s.on; }
- (void)swHpChanged:(UISwitch *)s     { g_autoHp         = s.on; }
- (void)swReviveChanged:(UISwitch *)s { g_autoRevive     = s.on; }
- (void)swEquipChanged:(UISwitch *)s  { g_autoEquip      = s.on; }
- (void)swZoomChanged:(UISwitch *)s {
    g_cameraZoomOn = s.on;
    void* cm = GetClientManagerInstance();
    if (cm) {
        void* characterCam = *(void**)((uint8_t*)cm + 0x38);
        if (characterCam && IsValidUnityObj(characterCam)) {
            void* cameraObj = *(void**)((uint8_t*)characterCam + 0x40);
            if (cameraObj && IsValidUnityObj(cameraObj)) {
                static void* set_orthoMI = nullptr;
                static void* cameraKlass = nullptr;
                if (!cameraKlass) cameraKlass = ScanFindClass("UnityEngine", "Camera");
                if (cameraKlass && !set_orthoMI)
                    set_orthoMI = FindMethodInHierarchy(cameraKlass, "set_orthographicSize", 1);
                if (set_orthoMI) {
                    float targetSize = g_cameraZoomOn ? g_cameraZoomValue : 5.0f;
                    void* params[1] = { &targetSize };
                    SafeInvoke(set_orthoMI, cameraObj, params);
                }
            }
        }
    }
}
- (void)swFpsChanged:(UISwitch *)s {
    g_showFps = s.on;
    if (_lblFpsBadge) _lblFpsBadge.hidden = !g_showFps;
}
- (void)swAutoWatchAdsChanged:(UISwitch *)s { g_autoWatchAds = s.on; }
- (void)swAutoSellKeyChanged:(UISwitch *)s {
    g_autoSellKey = s.on;
    [[NSUserDefaults standardUserDefaults] setBool:g_autoSellKey forKey:@"THTweak_AutoSellKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)swAutoSellIngredientChanged:(UISwitch *)s { g_autoSellIngredient = s.on; }
- (void)segSellIngredientQualityChanged:(UISegmentedControl *)s { g_autoSellIngredientQuality = (int32_t)s.selectedSegmentIndex; }
- (void)swRecipeMergeChanged:(UISwitch *)s {
    g_recipeMergeEnabled = s.on;
    if (g_recipeMergeEnabled && !g_currentRecipe.valid) {
        [self showRecipeInputDialog];
    }
    [[NSUserDefaults standardUserDefaults] setBool:g_recipeMergeEnabled forKey:@"THTweak_RecipeMerge"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)swRecipeMergeGoToFireChanged:(UISwitch *)s {
    g_recipeMergeGoToFire = s.on;
    [[NSUserDefaults standardUserDefaults] setBool:g_recipeMergeGoToFire forKey:@"THTweak_RecipeMergeGoToFire"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)btnRecipeInputPressed:(UIButton *)sender {
    [self showRecipeInputDialog];
}
- (void)btnClearRecipePressed:(UIButton *)sender {
    g_currentRecipe = RecipeData();
    g_recipeBase64 = @"";
    g_recipeMergeEnabled = false;
    if (_swRecipeMerge) _swRecipeMerge.on = NO;
    [self updateRecipeInfoLabel];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"THTweak_RecipeBase64"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"THTweak_RecipeMerge"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setStatusText:@"Đã xóa công thức ghép đá."];
}
- (void)updateRecipeInfoLabel {
    if (!_lblRecipeInfo) return;
    if (g_currentRecipe.valid && g_currentRecipe.formulas.size() > 0) {
        _lblRecipeInfo.text = [NSString stringWithFormat:@"Đã nạp: %s (%lu CT, %lu nhóm)",
                               g_currentRecipe.name.c_str(),
                               (unsigned long)g_currentRecipe.formulas.size(),
                               (unsigned long)g_currentRecipe.groups.size()];
        _lblRecipeInfo.textColor = CLR_GREEN;
    } else {
        _lblRecipeInfo.text = @"Chưa nạp công thức nào";
        _lblRecipeInfo.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    }
}
- (void)showRecipeInputDialog {
    NSString *title = @"💎 Nhập Công Thức Ghép Đá";
    NSString *msg = @"Dán mã Base64 từ https://shiuliuliu.github.io/treasurehunter/web/ vào đây:";

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Dán mã công thức (Base64)...";
        textField.text = g_recipeBase64;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"🌐 Mở trang tạo công thức" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:@"https://shiuliuliu.github.io/treasurehunter/web/"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"📋 Dán từ Clipboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *clip = [UIPasteboard generalPasteboard].string;
        if (clip && [clip length] > 0) {
            [self applyRecipeBase64String:clip];
        } else {
            [self setStatusText:@"Clipboard trống!"];
        }
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Áp dụng" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *txt = alert.textFields[0].text;
        [self applyRecipeBase64String:txt];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];

    [self.rootViewController presentViewController:alert animated:YES completion:nil];
}
- (void)applyRecipeBase64String:(NSString *)inputStr {
    if (!inputStr || [inputStr length] == 0) {
        [self setStatusText:@"Chưa nhập mã công thức!"];
        return;
    }
    NSString *clean = [inputStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    clean = [clean stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    clean = [clean stringByReplacingOccurrencesOfString:@" " withString:@""];
    while ([clean length] % 4 != 0) {
        clean = [clean stringByAppendingString:@"="];
    }

    NSData *data = [[NSData alloc] initWithBase64EncodedString:clean options:NSDataBase64DecodingIgnoreUnknownCharacters];
    RecipeData newRec;
    if (data && ParseRecipeData(data, newRec) && newRec.valid) {
        g_currentRecipe = newRec;
        g_recipeBase64 = [clean copy];
        g_recipeMergeEnabled = true;
        if (_swRecipeMerge) _swRecipeMerge.on = YES;
        [self updateRecipeInfoLabel];

        [[NSUserDefaults standardUserDefaults] setObject:g_recipeBase64 forKey:@"THTweak_RecipeBase64"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"THTweak_RecipeMerge"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self setStatusText:[NSString stringWithFormat:@"Đã nạp công thức: %s (%lu CT)", g_currentRecipe.name.c_str(), (unsigned long)g_currentRecipe.formulas.size()]];

        UIAlertController *succ = [UIAlertController alertControllerWithTitle:@"✅ Nạp thành công"
            message:[NSString stringWithFormat:@"Đã nạp: %s\nSố công thức: %lu\nSố nhóm: %lu",
                     g_currentRecipe.name.c_str(),
                     (unsigned long)g_currentRecipe.formulas.size(),
                     (unsigned long)g_currentRecipe.groups.size()]
            preferredStyle:UIAlertControllerStyleAlert];
        [succ addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self.rootViewController presentViewController:succ animated:YES completion:nil];
    } else {
        UIAlertController *err = [UIAlertController alertControllerWithTitle:@"❌ Lỗi định dạng"
            message:@"Mã công thức không đúng định dạng Base64 từ shiuliuliu.github.io/treasurehunter/web/.\nVui lòng kiểm tra lại mã đã sao chép!"
            preferredStyle:UIAlertControllerStyleAlert];
        [err addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleDefault handler:nil]];
        [self.rootViewController presentViewController:err animated:YES completion:nil];
    }
}
- (void)swAutoMergeIngredientChanged:(UISwitch *)s { g_autoMergeIngredient = s.on; }
- (void)segMergeIngredientQualityChanged:(UISegmentedControl *)s { g_autoMergeIngredientQuality = (int32_t)s.selectedSegmentIndex; }
- (void)swMobFilterChanged:(UISwitch *)s { g_mobFilterEnabled = s.on; }
- (void)swAvoidMobFilterChanged:(UISwitch *)s { g_avoidMobFilterEnabled = s.on; }
- (void)btnMobCategoryPressed:(UIButton *)sender {
    [self showMobFilterDialogForMode:NO];
}
- (void)btnAvoidMobCategoryPressed:(UIButton *)sender {
    [self showMobFilterDialogForMode:YES];
}

- (void)swAvoidPlayersChanged:(UISwitch *)s { g_avoidPlayers = s.on; }
- (void)sliderAvoidPlayerRangeChanged:(UISlider *)s {
    g_avoidPlayerRange = s.value;
    if (_lblAvoidPlayerRange) _lblAvoidPlayerRange.text = [NSString stringWithFormat:@"Khoảng cách né người: %.0fm", g_avoidPlayerRange];
}
- (void)swAutoQuitPlayerChanged:(UISwitch *)s { g_autoQuitNearPlayer = s.on; }
- (void)sliderAutoQuitPlayerRangeChanged:(UISlider *)s {
    g_autoQuitPlayerRange = s.value;
    if (_lblAutoQuitPlayerRange) _lblAutoQuitPlayerRange.text = [NSString stringWithFormat:@"Khoảng cách tự thoát: %.0fm", g_autoQuitPlayerRange];
}
- (void)swShowRangeCirclesChanged:(UISwitch *)s { g_showRangeCircles = s.on; }

static BOOL s_isAvoidFilterDialogMode = NO;

- (void)showMobFilterDialogForMode:(BOOL)isAvoidMode {
    s_isAvoidFilterDialogMode = isAvoidMode;
    [self attachWindowSceneIfNeeded];
    
    UIView *oldOverlay = [self viewWithTag:998877];
    if (oldOverlay) {
        [oldOverlay removeFromSuperview];
    }
    
    CGRect screenBounds = self.bounds;
    if (screenBounds.size.width <= 0 || screenBounds.size.height <= 0) {
        screenBounds = [UIScreen mainScreen].bounds;
    }
    
    UIView *overlay = [[UIView alloc] initWithFrame:screenBounds];
    overlay.tag = 998877;
    overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
    overlay.alpha = 0.0f;
    
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMobCategoryDialog)];
    [overlay addGestureRecognizer:tapBg];
    
    CGFloat boxW = 270.0f;
    CGFloat boxH = fminf(350.0f, screenBounds.size.height - 20.0f);
    
    UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake((screenBounds.size.width - boxW)/2, (screenBounds.size.height - boxH)/2, boxW, boxH)];
    dialog.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.13 alpha:0.96];
    dialog.layer.cornerRadius = 10.0f;
    dialog.layer.borderWidth = 1.5f;
    dialog.layer.borderColor = isAvoidMode ? [UIColor colorWithRed:1.0 green:0.55 blue:0.15 alpha:1.0].CGColor : CLR_PURP.CGColor;
    dialog.clipsToBounds = YES;
    
    // Header bar
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boxW, 36)];
    header.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.18 alpha:0.90];
    
    NSString *titleStr = isAvoidMode ? @"🛡️ CHỌN QUÁI CẦN NÉ" : @"🎯 CHỌN QUÁI CẦN FARM";
    UILabel *lblTitle = MakeLabel(titleStr, CGRectMake(12, 8, boxW - 48, 20), 12.0, isAvoidMode ? [UIColor colorWithRed:1.0 green:0.60 blue:0.20 alpha:1.0] : CLR_GREEN);
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    [header addSubview:lblTitle];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.frame = CGRectMake(boxW - 32, 4, 28, 28);
    [btnClose setTitle:@"✕" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
    btnClose.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    [btnClose addTarget:self action:@selector(dismissMobCategoryDialog) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btnClose];
    
    [dialog addSubview:header];
    
    // Divider
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(0, 36, boxW, 1)];
    div.backgroundColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.40];
    [dialog addSubview:div];
    
    // Scrollable options list
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 37, boxW, boxH - 37)];
    sv.showsVerticalScrollIndicator = YES;
    sv.alwaysBounceVertical = YES;
    
    CGFloat itemY = 6.0f;
    const CGFloat itemH = 32.0f;
    int32_t currentFilter = isAvoidMode ? g_selectedAvoidMobCategory : g_selectedMobCategory;
    
    for (NSInteger i = 0; i < kMobCategoryOptionCount; i++) {
        int32_t filterId = kMobCategoryOptions[i].filterId;
        BOOL isSelected = (currentFilter == filterId);
        
        UIButton *btnRow = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRow.frame = CGRectMake(8, itemY, boxW - 16, itemH);
        btnRow.layer.cornerRadius = 5.0f;
        btnRow.layer.borderWidth = 1.0f;
        btnRow.tag = 1000 + i;
        
        if (isSelected) {
            btnRow.backgroundColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.35];
            btnRow.layer.borderColor = CLR_GREEN.CGColor;
        } else {
            btnRow.backgroundColor = CLR_ROW;
            btnRow.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.4].CGColor;
        }
        
        UILabel *lblRow = [[UILabel alloc] initWithFrame:CGRectMake(8, 3, boxW - 16 - 32, 26)];
        lblRow.text = [NSString stringWithUTF8String:kMobCategoryOptions[i].displayName];
        lblRow.font = [UIFont fontWithName:isSelected ? @"HelveticaNeue-Bold" : @"HelveticaNeue-Medium" size:11.0];
        lblRow.textColor = isSelected ? CLR_GREEN : [UIColor whiteColor];
        lblRow.adjustsFontSizeToFitWidth = YES;
        [btnRow addSubview:lblRow];
        
        if (isSelected) {
            UILabel *lblCheck = [[UILabel alloc] initWithFrame:CGRectMake(boxW - 16 - 24, 3, 18, 26)];
            lblCheck.text = @"✓";
            lblCheck.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
            lblCheck.textColor = CLR_GREEN;
            lblCheck.textAlignment = NSTextAlignmentCenter;
            [btnRow addSubview:lblCheck];
        }
        
        [btnRow addTarget:self action:@selector(mobCategoryItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [sv addSubview:btnRow];
        
        itemY += itemH + 4.0f;
    }
    
    sv.contentSize = CGSizeMake(boxW, itemY + 6.0f);
    [dialog addSubview:sv];
    [overlay addSubview:dialog];
    [self addSubview:overlay];
    
    [UIView animateWithDuration:0.2 animations:^{
        overlay.alpha = 1.0f;
    }];
}

- (void)dismissMobCategoryDialog {
    UIView *overlay = [self viewWithTag:998877];
    if (overlay) {
        [UIView animateWithDuration:0.15 animations:^{
            overlay.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [overlay removeFromSuperview];
        }];
    }
}

- (void)mobCategoryItemSelected:(UIButton *)sender {
    NSInteger index = sender.tag - 1000;
    if (index >= 0 && index < kMobCategoryOptionCount) {
        int32_t filterId = kMobCategoryOptions[index].filterId;
        BOOL isAvoid = s_isAvoidFilterDialogMode;
        
        if (filterId == 999) {
            [self dismissMobCategoryDialog];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showCustomMobIdInputDialogForMode:isAvoid];
            });
            return;
        }
        
        if (isAvoid) {
            g_selectedAvoidMobCategory = filterId;
            if (_btnAvoidMobCategory) {
                [_btnAvoidMobCategory setTitle:GetMobFilterShortName(filterId, g_customAvoidMobFilterIds, g_customAvoidMobFilterName) forState:UIControlStateNormal];
            }
        } else {
            g_selectedMobCategory = filterId;
            if (_btnMobCategory) {
                [_btnMobCategory setTitle:GetMobFilterShortName(filterId, g_customMobFilterIds, g_customMobFilterName) forState:UIControlStateNormal];
            }
        }
    }
    [self dismissMobCategoryDialog];
}

- (void)showCustomMobIdInputDialogForMode:(BOOL)isAvoidMode {
    NSString *title = isAvoidMode ? @"🛡️ Tùy Chỉnh Quái Né" : @"🎯 Tùy Chỉnh Quái Farm";
    NSString *msg = @"Nhập danh sách ID quái (vd: 13, 21, 64) hoặc từ khóa tên quái (vd: Rex, Dragon):";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Nhập ID quái (vd: 13, 21, 64)";
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.text = isAvoidMode ? g_customAvoidMobFilterIds : g_customMobFilterIds;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Nhập từ khóa tên (vd: Rex, Dragon)";
        textField.text = isAvoidMode ? g_customAvoidMobFilterName : g_customMobFilterName;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Xác nhận" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *idText = alert.textFields[0].text;
        NSString *nameText = alert.textFields[1].text;
        
        if (isAvoidMode) {
            g_customAvoidMobFilterIds = idText ? [idText copy] : @"";
            g_customAvoidMobFilterName = nameText ? [nameText copy] : @"";
            g_selectedAvoidMobCategory = 999;
            if (self->_btnAvoidMobCategory) {
                [self->_btnAvoidMobCategory setTitle:GetMobFilterShortName(999, g_customAvoidMobFilterIds, g_customAvoidMobFilterName) forState:UIControlStateNormal];
            }
        } else {
            g_customMobFilterIds = idText ? [idText copy] : @"";
            g_customMobFilterName = nameText ? [nameText copy] : @"";
            g_selectedMobCategory = 999;
            if (self->_btnMobCategory) {
                [self->_btnMobCategory setTitle:GetMobFilterShortName(999, g_customMobFilterIds, g_customMobFilterName) forState:UIControlStateNormal];
            }
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)sliderDigChanged:(UISlider *)s {
    g_digRangeValue = s.value;
    if (_lblDigRange) _lblDigRange.text = [NSString stringWithFormat:@"Phạm vi tìm ô: %.0fm", g_digRangeValue];
}

- (void)sliderDigStopDistChanged:(UISlider *)s {
    g_digStopDist = s.value;
    if (_lblDigStopDist) _lblDigStopDist.text = [NSString stringWithFormat:@"Khoảng cách tâm ô: %.2fm", g_digStopDist];
}

- (void)sliderSpeedSensitivityChanged:(UISlider *)s {
    g_speedSensitivity = s.value;
    if (_lblSpeedSensitivity) _lblSpeedSensitivity.text = [NSString stringWithFormat:@"Độ nhạy phanh (Tốc độ): %.1fx", g_speedSensitivity];
}

- (void)sliderAttackChanged:(UISlider *)s {
    g_attackRangeValue = s.value;
    if (_lblAttackRange) _lblAttackRange.text = [NSString stringWithFormat:@"Phạm vi đánh: %.0fm", g_attackRangeValue];
}

- (void)sliderAvoidChanged:(UISlider *)s {
    g_avoidRangeValue = s.value;
    if (_lblAvoidRange) _lblAvoidRange.text = [NSString stringWithFormat:@"Phạm vi né quái: %.0fm", g_avoidRangeValue];
}

- (void)swMobMinChanged:(UISwitch *)s {
    g_attackMobFilterMin = s.on;
}

- (void)swMobMaxChanged:(UISwitch *)s {
    g_attackMobFilterMax = s.on;
}

- (void)sliderMobMinHpChanged:(UISlider *)s {
    g_attackMobMinHp = s.value;
    if (_lblMobMinHp) _lblMobMinHp.text = [NSString stringWithFormat:@"HP quái lớn hơn: %.0f", g_attackMobMinHp];
    
    // Constraint: MaxHp must be at least MinHp + 200
    if (g_attackMobMaxHp < g_attackMobMinHp + 200.0f) {
        g_attackMobMaxHp = g_attackMobMinHp + 200.0f;
        if (g_attackMobMaxHp > 2000.0f) g_attackMobMaxHp = 2000.0f;
        if (_sliderMobMaxHp) _sliderMobMaxHp.value = g_attackMobMaxHp;
        if (_lblMobMaxHp) _lblMobMaxHp.text = [NSString stringWithFormat:@"HP quái nhỏ hơn: %.0f", g_attackMobMaxHp];
    }
}

- (void)sliderMobMaxHpChanged:(UISlider *)s {
    g_attackMobMaxHp = s.value;
    
    // Constraint: MaxHp cannot be less than MinHp + 200
    if (g_attackMobMaxHp < g_attackMobMinHp + 200.0f) {
        g_attackMobMaxHp = g_attackMobMinHp + 200.0f;
        if (g_attackMobMaxHp > 2000.0f) g_attackMobMaxHp = 2000.0f;
        s.value = g_attackMobMaxHp;
    }
    if (_lblMobMaxHp) _lblMobMaxHp.text = [NSString stringWithFormat:@"HP quái nhỏ hơn: %.0f", g_attackMobMaxHp];
}

- (void)sliderHpChanged:(UISlider *)s {
    g_autoHpPercent = s.value;
    if (_lblHpPercent) _lblHpPercent.text = [NSString stringWithFormat:@"Dùng khi HP < %.0f%%", g_autoHpPercent*100];
}

- (void)segEquipChanged:(UISegmentedControl *)s {
    g_autoEquipQuality = (int32_t)s.selectedSegmentIndex;
}

- (void)swReturnChanged:(UISwitch *)s {
    g_returnToDeathPos = s.on;
}

- (void)swMasterChanged:(UISwitch *)s {
    g_menuMasterSwitch = s.on;
    if (!g_menuMasterSwitch) {
        g_hasCachedTarget = false;
        g_currentTargetObj = nullptr;
        g_isAtTarget = false;
        void* playerMovement = GetLocalPlayerMovement();
        if (playerMovement) {
            static void* setExternalInputMI = nullptr;
            static void* pmKlass = nullptr;
            if (!pmKlass) pmKlass = ScanFindClass("", "AuthorativePlayerMovement");
            if (pmKlass && !setExternalInputMI) setExternalInputMI = FindMethodInHierarchy(pmKlass, "SetExternalInput", 1);
            if (setExternalInputMI) {
                Vector2 zero = { 0.0f, 0.0f };
                void* params[1] = { &zero };
                SafeInvoke(setExternalInputMI, playerMovement, params);
            }
        }
    }
}

- (void)sliderZoomChanged:(UISlider *)s {
    g_cameraZoomValue = s.value;
    if (_lblZoomValue) _lblZoomValue.text = [NSString stringWithFormat:@"Độ rộng tầm nhìn: %.1f", g_cameraZoomValue];
    
    // Immediately apply zoom if Camera Zoom is ON
    if (g_cameraZoomOn) {
        void* cm = GetClientManagerInstance();
        if (cm) {
            void* characterCam = *(void**)((uint8_t*)cm + 0x38);
            if (characterCam && IsValidUnityObj(characterCam)) {
                void* cameraObj = *(void**)((uint8_t*)characterCam + 0x40);
                if (cameraObj && IsValidUnityObj(cameraObj)) {
                    static void* set_orthoMI = nullptr;
                    static void* cameraKlass = nullptr;
                    if (!cameraKlass) cameraKlass = ScanFindClass("UnityEngine", "Camera");
                    if (cameraKlass && !set_orthoMI)
                        set_orthoMI = FindMethodInHierarchy(cameraKlass, "set_orthographicSize", 1);
                    if (set_orthoMI) {
                        float size = g_cameraZoomValue;
                        void* params[1] = { &size };
                        SafeInvoke(set_orthoMI, cameraObj, params);
                    }
                }
            }
        }
    }
}

- (void)togglePanel:(UIButton *)sender { _panel.hidden = !_panel.hidden; }
- (void)drag:(UIPanGestureRecognizer *)pan {
    CGPoint t = [pan translationInView:self];
    pan.view.center = CGPointMake(pan.view.center.x + t.x, pan.view.center.y + t.y);
    [pan setTranslation:CGPointZero inView:self];
}
- (void)dragPanel:(UIPanGestureRecognizer *)pan {
    CGPoint t = [pan translationInView:self];
    CGPoint c = _panel.center;
    _panel.center = CGPointMake(c.x + t.x, c.y + t.y);
    [pan setTranslation:CGPointZero inView:self];
}

- (void)openFacebook:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/shinliumod.vn"] options:@{} completionHandler:nil];
}

- (void)openTelegram:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/shiuliuliu"] options:@{} completionHandler:nil];
}

- (void)openYoutube:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.youtube.com/@ShiuliuliuGamer"] options:@{} completionHandler:nil];
}

- (void)openGroupTelegram:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://t.me/+z5iYI9TXOmphNmM1"] options:@{} completionHandler:nil];
}

@end

// =============================================
// Device UDID and Model Info
// =============================================
static NSString* GetDeviceUDID() {
    static NSString *s_cachedUDID = nil;
    if (s_cachedUDID && [s_cachedUDID length] > 0) return s_cachedUDID;
    
    // 1. Try reading persistent UDID from Keychain
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: @"com.treasuhunter.tweak.udid",
        (__bridge id)kSecAttrAccount: @"DeviceUDID",
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess && result) {
        NSData *data = (__bridge_transfer NSData*)result;
        NSString *udidFromKeychain = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (udidFromKeychain && [udidFromKeychain length] > 0) {
            s_cachedUDID = udidFromKeychain;
            [[NSUserDefaults standardUserDefaults] setObject:s_cachedUDID forKey:@"THTweak_CachedUDID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return s_cachedUDID;
        }
    }
    
    // 2. Fallback to NSUserDefaults
    NSString *udid = [[NSUserDefaults standardUserDefaults] stringForKey:@"THTweak_CachedUDID"];
    if (!udid || [udid length] == 0) {
        udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if (!udid || [udid length] == 0) {
            udid = [[NSUUID UUID] UUIDString];
        }
        [[NSUserDefaults standardUserDefaults] setObject:udid forKey:@"THTweak_CachedUDID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 3. Save to Keychain to survive app reinstalls
    NSData *udidData = [udid dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *addQuery = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: @"com.treasuhunter.tweak.udid",
        (__bridge id)kSecAttrAccount: @"DeviceUDID",
        (__bridge id)kSecValueData: udidData,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock
    };
    SecItemAdd((__bridge CFDictionaryRef)addQuery, NULL);
    
    s_cachedUDID = udid;
    return s_cachedUDID;
}

#include <sys/sysctl.h>
static NSString* GetDeviceModel() {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone15,2"]) return @"iPhone 14 Pro";
    if ([platform isEqualToString:@"iPhone15,3"]) return @"iPhone 14 Pro Max";
    if ([platform isEqualToString:@"iPhone15,4"]) return @"iPhone 15";
    if ([platform isEqualToString:@"iPhone15,5"]) return @"iPhone 15 Plus";
    if ([platform isEqualToString:@"iPhone16,1"]) return @"iPhone 15 Pro";
    if ([platform isEqualToString:@"iPhone16,2"]) return @"iPhone 15 Pro Max";
    if ([platform isEqualToString:@"iPhone17,1"]) return @"iPhone 16 Pro";
    if ([platform isEqualToString:@"iPhone17,2"]) return @"iPhone 16 Pro Max";
    if ([platform isEqualToString:@"iPhone17,3"]) return @"iPhone 16";
    if ([platform isEqualToString:@"iPhone17,4"]) return @"iPhone 16 Plus";
    
    NSString *model = [[UIDevice currentDevice] model];
    return [NSString stringWithFormat:@"%@ (%@)", model, platform];
}

// =============================================
// API Key Verification Logic
// =============================================
static void VerifyKeyAPI(NSString *key, NSString *udid, void (^completion)(BOOL success, NSString *message, NSString *expiry)) {
    NSString *escapedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *escapedUdid = [udid stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *escapedDevice = [GetDeviceModel() stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?action=checkKey&key=%@&udid=%@&device=%@", LICENSE_API_URL, escapedKey, escapedUdid, escapedDevice];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            completion(NO, [NSString stringWithFormat:@"Lỗi kết nối: %@", error.localizedDescription], nil);
            return;
        }
        
        if (!data) {
            completion(NO, @"Không nhận được dữ liệu từ máy chủ", nil);
            return;
        }
        
        NSError *jsonErr = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
        if (jsonErr || !json) {
            completion(NO, @"Lỗi giải mã phản hồi từ máy chủ", nil);
            return;
        }
        
        NSString *status = json[@"status"];
        NSString *message = json[@"message"] ? json[@"message"] : @"";
        NSString *expiry = json[@"expiry"] ? json[@"expiry"] : @"";
        
        if ([status isEqualToString:@"success"]) {
            completion(YES, message, expiry);
        } else {
            completion(NO, message, nil);
        }
    }];
    [task resume];
}

// Check license: Always verify if machine UDID has an active key on system
static void CheckDeviceLicense(void (^completion)(BOOL success, NSString *keyUsed, NSString *expiry, NSString *errMsg)) {
    NSString *udid = GetDeviceUDID();
    NSString *savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"THTweak_LicenseKey"];
    
    // Priority 1: Check saved key if exists and not CHECK_UDID_ONLY
    if (savedKey && [savedKey length] > 0 && ![savedKey isEqualToString:@"CHECK_UDID_ONLY"]) {
        VerifyKeyAPI(savedKey, udid, ^(BOOL success, NSString *message, NSString *expiry) {
            if (success) {
                completion(YES, savedKey, expiry, nil);
            } else {
                // Saved key failed (e.g. key expired or admin assigned a new key for this machine on sheet)
                // Priority 2: Check directly if this machine UDID is active on the system!
                VerifyKeyAPI(@"CHECK_UDID_ONLY", udid, ^(BOOL success2, NSString *message2, NSString *expiry2) {
                    if (success2) {
                        [[NSUserDefaults standardUserDefaults] setObject:@"CHECK_UDID_ONLY" forKey:@"THTweak_LicenseKey"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        completion(YES, @"CHECK_UDID_ONLY", expiry2, nil);
                    } else {
                        completion(NO, nil, nil, (message2 && [message2 length] > 0) ? message2 : message);
                    }
                });
            }
        });
    } else {
        // Priority 2: Check directly by machine UDID
        VerifyKeyAPI(@"CHECK_UDID_ONLY", udid, ^(BOOL success, NSString *message, NSString *expiry) {
            if (success) {
                [[NSUserDefaults standardUserDefaults] setObject:@"CHECK_UDID_ONLY" forKey:@"THTweak_LicenseKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                completion(YES, @"CHECK_UDID_ONLY", expiry, nil);
            } else {
                completion(NO, nil, nil, message);
            }
        });
    }
}

// =============================================
// Licensing / Activation GUI Window
// =============================================
@interface THActivationWindow : UIWindow <UITextFieldDelegate>
{
    UIView *_panel;
    UILabel *_lblTitle;
    UILabel *_lblSubtitle;
    UILabel *_lblDeviceID;
    UIButton *_btnCopyID;
    UITextField *_txtKey;
    UIButton *_btnActivate;
    UILabel *_lblStatus;
    UIActivityIndicatorView *_spinner;
}
@end

@implementation THActivationWindow

- (void)attachWindowSceneIfNeeded {
    if (@available(iOS 13.0, *)) {
        if (!self.windowScene) {
            UIWindowScene *scene = GetActiveWindowScene();
            if (scene) {
                self.windowScene = scene;
            }
        }
    }
}

- (instancetype)init {
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        [self attachWindowSceneIfNeeded];
        
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.view.frame = self.bounds;
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.rootViewController = vc;
        
        self.windowLevel = UIWindowLevelAlert + 110;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
        self.userInteractionEnabled = YES;
        self.hidden = NO;
        
        [self buildUI];
        [self attachWindowSceneIfNeeded];
        [self makeKeyAndVisible];
        
        // Auto-check machine UDID on launch
        [self autoCheckDeviceOnSystem];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self attachWindowSceneIfNeeded];
}

- (void)buildUI {
    CGFloat sw = self.bounds.size.width;
    CGFloat sh = self.bounds.size.height;
    
    CGFloat pw = 300;
    CGFloat ph = 280;
    
    _panel = [[UIView alloc] initWithFrame:CGRectMake((sw - pw)/2, (sh - ph)/2, pw, ph)];
    _panel.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.13 alpha:0.92];
    _panel.layer.cornerRadius = 8.0f;
    _panel.layer.borderWidth = 1.5f;
    _panel.layer.borderColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.7].CGColor;
    
    _panel.layer.shadowColor = [UIColor blackColor].CGColor;
    _panel.layer.shadowOffset = CGSizeMake(0, 4);
    _panel.layer.shadowOpacity = 0.6;
    _panel.layer.shadowRadius = 8.0f;
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = _panel.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurView.layer.cornerRadius = 8.0f;
    blurView.clipsToBounds = YES;
    [_panel addSubview:blurView];
    
    _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, 16, pw - 24, 22)];
    _lblTitle.text = @"⚡ KÍCH HOẠT TWEAK VIP";
    _lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
    _lblTitle.textColor = [UIColor colorWithRed:0.20 green:0.95 blue:0.55 alpha:1.0];
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    [_panel addSubview:_lblTitle];
    
    _lblSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(12, 42, pw - 24, 16)];
    _lblSubtitle.text = @"Treasure Hunter Mod Menu";
    _lblSubtitle.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0];
    _lblSubtitle.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    _lblSubtitle.textAlignment = NSTextAlignmentCenter;
    [_panel addSubview:_lblSubtitle];
    
    NSString *udid = GetDeviceUDID();
    NSString *displayUdid = [udid length] > 16 ? [NSString stringWithFormat:@"...%@", [udid substringFromIndex:[udid length] - 12]] : udid;
    
    _lblDeviceID = [[UILabel alloc] initWithFrame:CGRectMake(16, 75, 175, 28)];
    _lblDeviceID.text = [NSString stringWithFormat:@"Mã máy: %@", displayUdid];
    _lblDeviceID.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _lblDeviceID.font = [UIFont fontWithName:@"HelveticaNeue" size:10.5];
    [_panel addSubview:_lblDeviceID];
    
    _btnCopyID = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCopyID.frame = CGRectMake(pw - 16 - 80, 75, 80, 28);
    _btnCopyID.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.22 alpha:0.90];
    _btnCopyID.layer.cornerRadius = 4.0f;
    _btnCopyID.layer.borderWidth = 0.8f;
    _btnCopyID.layer.borderColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.4].CGColor;
    [_btnCopyID setTitle:@"Sao Chép" forState:UIControlStateNormal];
    [_btnCopyID setTitleColor:[UIColor colorWithRed:0.80 green:0.60 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    _btnCopyID.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.5];
    [_btnCopyID addTarget:self action:@selector(copyDeviceID) forControlEvents:UIControlEventTouchUpInside];
    [_panel addSubview:_btnCopyID];
    
    _txtKey = [[UITextField alloc] initWithFrame:CGRectMake(16, 115, pw - 32, 38)];
    _txtKey.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.10 alpha:0.90];
    _txtKey.textColor = [UIColor whiteColor];
    _txtKey.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.5];
    _txtKey.textAlignment = NSTextAlignmentCenter;
    _txtKey.borderStyle = UITextBorderStyleLine;
    _txtKey.layer.cornerRadius = 4.0f;
    _txtKey.layer.borderWidth = 1.0f;
    _txtKey.layer.borderColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.5].CGColor;
    _txtKey.delegate = self;
    _txtKey.autocorrectionType = UITextAutocorrectionTypeNo;
    _txtKey.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    _txtKey.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Nhập Key kích hoạt..." attributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1.0],
        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0]
    }];
    [_panel addSubview:_txtKey];
    
    _btnActivate = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnActivate.frame = CGRectMake(16, 168, pw - 32, 38);
    _btnActivate.backgroundColor = [UIColor colorWithRed:0.62 green:0.32 blue:0.95 alpha:0.90];
    _btnActivate.layer.cornerRadius = 4.0f;
    [_btnActivate setTitle:@"KÍCH HOẠT NGAY" forState:UIControlStateNormal];
    [_btnActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnActivate.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    [_btnActivate addTarget:self action:@selector(attemptActivation) forControlEvents:UIControlEventTouchUpInside];
    [_panel addSubview:_btnActivate];
    
    _lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(16, 218, pw - 32, 45)];
    _lblStatus.text = @"Vui lòng liên hệ Admin @shiuliuliu để lấy Key kích hoạt.";
    _lblStatus.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    _lblStatus.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.5];
    _lblStatus.textAlignment = NSTextAlignmentCenter;
    _lblStatus.numberOfLines = 3;
    [_panel addSubview:_lblStatus];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _spinner.frame = CGRectMake(pw - 40, 178, 20, 20);
    _spinner.hidesWhenStopped = YES;
    [_panel addSubview:_spinner];
    
    [self.rootViewController.view addSubview:_panel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self attemptActivation];
    return YES;
}

- (void)copyDeviceID {
    [UIPasteboard generalPasteboard].string = GetDeviceUDID();
    
    [UIView animateWithDuration:0.15 animations:^{
        self->_btnCopyID.backgroundColor = [UIColor colorWithRed:0.20 green:0.75 blue:0.40 alpha:0.90];
        [self->_btnCopyID setTitle:@"Đã Chép!" forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.15 animations:^{
                self->_btnCopyID.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.22 alpha:0.90];
                [self->_btnCopyID setTitle:@"Sao Chép" forState:UIControlStateNormal];
            }];
        });
    }];
}

- (void)autoCheckDeviceOnSystem {
    _lblStatus.text = @"⏳ Đang kiểm tra mã máy trên hệ thống...";
    _lblStatus.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [_spinner startAnimating];
    
    VerifyKeyAPI(@"CHECK_UDID_ONLY", GetDeviceUDID(), ^(BOOL success, NSString *message, NSString *expiry) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_spinner stopAnimating];
            if (success) {
                self->_lblStatus.text = [NSString stringWithFormat:@"✅ Máy đã được cấp quyền VIP!\nHạn dùng đến: %@", expiry];
                self->_lblStatus.textColor = [UIColor colorWithRed:0.20 green:0.95 blue:0.55 alpha:1.0];
                
                [[NSUserDefaults standardUserDefaults] setObject:@"CHECK_UDID_ONLY" forKey:@"THTweak_LicenseKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissAndOpenTweakMenu];
                });
            } else {
                self->_lblStatus.text = @"Vui lòng liên hệ Admin @shiuliuliu để lấy Key kích hoạt.";
                self->_lblStatus.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
            }
        });
    });
}

- (void)attemptActivation {
    NSString *keyInput = [_txtKey.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *keyToCheck = ([keyInput length] > 0) ? keyInput : @"CHECK_UDID_ONLY";
    
    [self setControlsEnabled:NO];
    _lblStatus.text = ([keyInput length] > 0) ? @"⏳ Đang xác thực key với máy chủ..." : @"⏳ Đang kiểm tra mã máy trên hệ thống...";
    _lblStatus.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [_spinner startAnimating];
    
    VerifyKeyAPI(keyToCheck, GetDeviceUDID(), ^(BOOL success, NSString *message, NSString *expiry) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_spinner stopAnimating];
            if (success) {
                self->_lblStatus.text = [NSString stringWithFormat:@"✅ Kích hoạt thành công!\nHạn dùng đến: %@", expiry];
                self->_lblStatus.textColor = [UIColor colorWithRed:0.20 green:0.95 blue:0.55 alpha:1.0];
                
                [[NSUserDefaults standardUserDefaults] setObject:keyToCheck forKey:@"THTweak_LicenseKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissAndOpenTweakMenu];
                });
            } else {
                [self setControlsEnabled:YES];
                self->_lblStatus.text = [NSString stringWithFormat:@"❌ %@", message];
                self->_lblStatus.textColor = [UIColor colorWithRed:1.0 green:0.35 blue:0.35 alpha:1.0];
            }
        });
    });
}

- (void)setControlsEnabled:(BOOL)enabled {
    _txtKey.enabled = enabled;
    _btnActivate.enabled = enabled;
    _btnCopyID.enabled = enabled;
    _btnActivate.alpha = enabled ? 1.0f : 0.6f;
}

- (void)dismissAndOpenTweakMenu {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self setHidden:YES];
        g_activationWindow = nil;
        
        g_window = [[THTweakWindow alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer *_) {
            TickCheats();
        }];
    }];
}

@end

// =============================================
// Constructor
// =============================================
__attribute__((constructor)) static void entry() {
    @autoreleasepool {
        InstallSafeSignalHandlers();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            static int s_initAttempts = 0;
            NSTimer* initTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 repeats:YES block:^(NSTimer *t) {
                s_initAttempts++;
                Il2CppAttach();
                if (s_attached) {
                    static bool triggered = false;
                    if (!triggered) {
                        void* marker = ScanFindClass("", "WorldManager");
                        if (!marker) marker = ScanFindClass("", "PlayerMovement");
                        if (!marker) marker = ScanFindClass("", "ClientManager");
                        if (!marker) marker = ScanFindClass("UnityEngine", "Object");
                        
                        if (marker || s_initAttempts >= 8) {
                            triggered = true;
                            
                            // Auto Watch Ads Setup
                            void* hudViewKlass = ScanFindClass("", "HUDView");
                            if (hudViewKlass) {
                                void* requestAd_mi = FindMethodInHierarchy(hudViewKlass, "RequestAd", 0);
                                if (requestAd_mi) {
                                    HookIl2CppMethod(requestAd_mi, (void*)&new_HUDView_RequestAd, (void**)&orig_HUDView_RequestAd);
                                    NSLog(@"[THTweak] Hooked HUDView.RequestAd successfully");
                                }
                            }
                            
                            // License Check: Immediately approves if machine UDID or saved key is active on Google Sheets
                            CheckDeviceLicense(^(BOOL success, NSString *keyUsed, NSString *expiry, NSString *errMsg) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (success) {
                                        NSLog(@"[THTweak] Device authorized! Key: %@, Expiry: %@", keyUsed, expiry);
                                        g_window = [[THTweakWindow alloc] init];
                                        [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer *_) {
                                            TickCheats();
                                        }];
                                    } else {
                                        g_activationWindow = [[THActivationWindow alloc] init];
                                    }
                                });
                            });
                            
                            [t invalidate];
                        }
                    }
                }
            }];
            [[NSRunLoop mainRunLoop] addTimer:initTimer forMode:NSRunLoopCommonModes];
        });
    }
}
