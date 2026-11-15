# UGeT UI

Obsidianの設計思想を研究した上で、ゼロから設計・実装した**完全オリジナルのRoblox Luau UIライブラリ**。
by **FOX & Wase**

## 特徴
- 左サイドバー型レイアウト（狭い画面では自動でアイコンレール＋1カラム化）
- インラインアコーディオン式 Dropdown / ColorPicker（オーバーレイ不要でモバイルに強い）
- Toggle / Slider / Dropdown / Input / ColorPicker / Keybind / Button
- **Asset Inspector**: IDを貼るだけで画像・音声・動画・3Dモデルを自動判別プレビュー＋IDコピー
- **VideoFrame / 3D Viewport（orbit + spin） / WebLink（URLコピー + Ping）**
- `Library:Fetch` HTTPブリッジ（UGeTサイト等との連携用）
- テーマプリセット4種 + ライブカスタマイズ、コンフィグ保存/自動ロード
- PC / モバイル両対応、`require`不要のモジュール注入方式

## セットアップ（Roblox Studio）
1. このリポジトリを `UGeT-UI` という名前のFolderとして `ReplicatedStorage` に配置
   （各 `.lua` はModuleScriptに変換、`Examples/Main.lua` だけScriptにする）
2. 実行:
```lua
local Library = require(game.ReplicatedStorage["UGeT-UI"].Library)
local Window = Library:CreateWindow({ Title = "UGeT UI" })
local Main = Window:AddTab("Main")
Main:AddButton("Test Button", function()
    print("UGeT UI")
end)
```

## セットアップ（Executor / ブートストラップ）
```lua
local BASE = "https://raw.githubusercontent.com/WaseranYaro8/UGeT-UI/main/"
local function get(p) return loadstring(game:HttpGet(BASE .. p))() end
local Library = get("Library.lua")
Library.Use({
    Utility = get("Core/Utility.lua"),
    Theme = get("Core/Theme.lua"),
    Layout = get("Core/Layout.lua"),
    Window = get("Core/Window.lua"),
    Tab = get("Core/Tab.lua"),
    Button = get("Components/Button.lua"),
    Toggle = get("Components/Toggle.lua"),
    Slider = get("Components/Slider.lua"),
    Dropdown = get("Components/Dropdown.lua"),
    Input = get("Components/Input.lua"),
    ColorPicker = get("Components/ColorPicker.lua"),
    Keybind = get("Components/Keybind.lua"),
    Asset = get("Components/Asset.lua"),
    Video = get("Components/Video.lua"),
    Viewport = get("Components/Viewport.lua"),
    Web = get("Components/Web.lua"),
    Notifications = get("Addons/Notifications.lua"),
    ThemeManager = get("Addons/ThemeManager.lua"),
    SaveManager = get("Addons/SaveManager.lua"),
})
Library.Init()
```

## API早見表
| 呼び出し | 説明 |
|---|---|
| `Library:CreateWindow{Title, Subtitle, Width, Height}` | ウィンドウ生成 |
| `Window:AddTab(name, icon?)` | タブ追加 |
| `Tab:AddSection(title, "Left"/"Right")` | カード追加 |
| `AddButton(text, fn)` / `{Text, Func, Variant, DoubleClick}` | ボタン |
| `AddToggle(flag, {Text, Default, Callback, Risky})` | スイッチ |
| `AddSlider(flag, {Text, Min, Max, Default, Rounding, Suffix, Callback})` | スライダー（値タップで数値入力） |
| `AddDropdown(flag, {Text, Values, Default, Multi, Searchable, AllowNull, SpecialType="Player", Callback})` | ドロップダウン |
| `AddInput(flag, {Text, Placeholder, Numeric, Finished, Callback})` | テキスト入力 |
| `AddColorPicker(flag, {Text, Default, Transparency, Callback})` | カラー（HSV+Hex+Alpha） |
| `AddKeybind(flag, {Text, Default, Mode, SyncWith, Callback})` | キーバインド（Toggle/Hold/Press） |
| `AddAsset{Default, Type, Callback}` | アセットID自動プレビュー |
| `AddVideo{Video, Height, Looped, Playing}` | 動画 |
| `AddViewport{Model / AssetId, Height, Spin}` | 3Dプレビュー |
| `AddWebLink{Title, Url, Description}` | サイトカード |
| `Library:Notify{Title, Text, Type, Time}` | 通知 |
| `Library:Fetch(url, {Method, Body, Headers})` | HTTPブリッジ |
| `Library.Flags[name]:SetValue(v)` | 全フラグ共通 |
| `Library:Destroy()` | 完全アンロード |

## Termux → GitHub 公開
```bash
cd UGeT-UI
git init && git add . && git commit -m "UGeT UI v1.0.0"
git branch -M main
git remote add origin https://github.com/WaseranYaro8/UGeT-UI.git
git push -u origin main
```

## License
MIT — Copyright (c) 2026 FOX & Wase
