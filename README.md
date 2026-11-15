# UGeT UI

Roblox で使える自作の UI ライブラリです。ウィンドウ・タブ・各種コントロールを少ないコードで組み立てられます。パソコンとスマートフォンの両方に対応しています。

## 読み込み方

次の 1 行を実行するだけで読み込めます。

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/UGeT-UI-official/UI/main/UGeT.lua"))()
```

読み込むと動作確認用のサンプルウィンドウが開きます。ご自身の UI だけを作りたい場合は、読み込む前に次の 1 行を置いてください。

```lua
getgenv().UGET_NO_DEMO = true
```

## 基本の考え方

「ウィンドウ → タブ → セクション → コントロール」の順に組み立てます。

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UGeT-UI-official/UI/main/UGeT.lua"))()
local Window = Library:CreateWindow({ Title = "UGeT" })
local Tab = Window:AddTab("Main")
Tab:AddButton("Hello", function()
    print("UGeT")
end)
```

コントロールを追加するときは次の形を使います。

```lua
Tab:AddXxx("フラグ名", { オプション })
```

- **フラグ名**: そのコントロールを識別する名前です。設定の保存や、あとから値を変更するときに使います。
- **オプション**: テーブルで見た目と動作を指定します。

セクションでグループ分けすると見やすくなります。位置は `"Left"` か `"Right"` で指定します。見出しを押すと折りたためます。

```lua
local Section = Tab:AddSection("タイトル", "Left")
Section:AddToggle("my_toggle", { Text = "有効", Default = false })
```

## ウィンドウ

```lua
local Window = Library:CreateWindow({
    Title = "UGeT",
    Subtitle = "サンプル",
    Width = 640,
    Height = 460,
})
```

| オプション | 意味 |
|---|---|
| Title | 左上に表示する名前です |
| Subtitle | 名前の下に出る小さな文字です |
| Width / Height | 初期サイズです（スマホでは自動で画面にフィットします） |

操作: 上部バーをドラッグで移動、右下のつまみでサイズ変更、「−」で最小化、「×」を2回で閉じます。ピンボタンで移動とサイズ変更を固定できます。

```lua
Window:SetTitle("新しい名前")
Window:SetVisible(false)
Window:SetLocked(true)
```

## タブ

```lua
local Tab = Window:AddTab("Main", "M")
```

第2引数はアイコン用の文字です（省略可）。タブ全体を一括で有効/無効にできます。

```lua
Tab:SetEnabled(false)
```

## Button（ボタン）

```lua
Tab:AddButton("実行", function()
    print("押されました")
end)
```

```lua
Tab:AddButton({
    Text = "削除",
    Variant = "Danger",
    DoubleClick = true,
    Func = function()
        print("削除しました")
    end,
})
```

| オプション | 意味 |
|---|---|
| Text | ボタンの文字です |
| Func | 押したときに動く関数です |
| Variant | `"Accent"`（強調）/ `"Danger"`（赤）を指定できます |
| DoubleClick | `true` で2回押さないと実行されません（誤操作防止） |
| Tooltip | カーソルを乗せたときに出る説明です |

## Toggle（オン/オフ）

```lua
Tab:AddToggle("my_toggle", {
    Text = "有効にする",
    Default = false,
    Callback = function(value)
        print("現在:", value)
    end,
})
```

| オプション | 意味 |
|---|---|
| Text | 表示する文字です |
| Default | 初期状態（`true` / `false`）です |
| Callback | 切り替わったときに動く関数です |
| Risky | `true` で文字が赤くなります（注意が必要な機能向け） |
| Tooltip | ホバー時の説明です |

## Slider（数値）

```lua
Tab:AddSlider("speed", {
    Text = "スピード",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 5,
    Callback = function(value)
        print(value)
    end,
})
```

バーをドラッグして変更できます。右の「−」「＋」で細かく調整でき、数値を押すと直接入力できます。

| オプション | 意味 |
|---|---|
| Min / Max | 最小値と最大値です |
| Default | 初期値です |
| Step | 「−」「＋」1回で変わる量です |
| Rounding | 小数の桁数です（`0` で整数） |
| Suffix | 数値の後ろに付ける文字です（例: `"x"`、`"%"`） |
| Callback | 値が変わったときに動く関数です |

## Dropdown（選択）

```lua
Tab:AddDropdown("mode", {
    Text = "モード",
    Values = { "Off", "Safe", "Fast" },
    Default = 1,
    Searchable = true,
    Callback = function(value)
        print(value)
    end,
})
```

| オプション | 意味 |
|---|---|
| Values | 選択肢の一覧です |
| Default | 初期選択です（番号か文字） |
| Multi | `true` で複数選択できます |
| Searchable | `true` で検索欄が付きます |
| AllowNull | `true` で未選択を許します |
| SpecialType | `"Player"` で参加者一覧が自動で並びます |
| Callback | 選択が変わったときに動く関数です |

## Input（文字入力）

```lua
Tab:AddInput("name", {
    Text = "名前",
    Placeholder = "入力してください",
    Finished = true,
    Callback = function(text)
        print(text)
    end,
})
```

| オプション | 意味 |
|---|---|
| Placeholder | 空欄のときに出る薄い文字です |
| Numeric | `true` で数字以外を入力できなくします |
| Finished | `true` で入力確定時にだけ Callback が動きます |
| Callback | 文字が変わった/確定したときに動く関数です |

## ColorPicker（色）

```lua
Tab:AddColorPicker("color", {
    Text = "色",
    Default = Color3.fromRGB(64, 220, 180),
    Transparency = 0,
    Callback = function(color, alpha)
        print(color, alpha)
    end,
})
```

色相・彩度・明度で選べます。16進数（例: `#40DCB4`）での入力にも対応します。`Transparency` を指定すると透明度も扱えます。

## Keybind（キー割り当て）

```lua
Tab:AddKeybind("key", {
    Text = "機能キー",
    Default = "G",
    Mode = "Toggle",
    Callback = function(state)
        print(state)
    end,
})
```

| オプション | 意味 |
|---|---|
| Default | 初期キーです（`"G"`、`"RightControl"` など） |
| Mode | `"Toggle"`（押すたびに切替）/ `"Hold"`（押している間）/ `"Press"`（押した瞬間） |
| SyncWith | 別のトグルのフラグ名を指定すると、そのトグルと連動します |
| Callback | 状態が変わったときに動く関数です |

キーのボタンを押してから任意のキーを押すと割り当てられます。Esc で解除できます。

## Label / Paragraph / Divider（表示）

```lua
Tab:AddLabel("ただの文字です")
Tab:AddParagraph("見出し", "長めの説明文です。自動で折り返されます。")
Tab:AddDivider()
```

## Asset（アセット確認）

アセット ID を貼ると、画像・音声・動画・モデルを自動で判別してプレビューします。ID のコピーもできます。

```lua
Tab:AddAsset({})
```

## Video（動画）

```lua
Tab:AddVideo({ Video = "rbxassetid://0", Height = 140, Looped = true })
```

`Video` に Roblox の動画アセットを指定します。再生/一時停止とループの切り替えができます。

## Viewport（3D 表示）

```lua
local part = Instance.new("Part")
part.Size = Vector3.new(2, 2, 2)
Tab:AddViewport({ Model = part, Height = 160, Spin = true })
```

`Model` にインスタンス、または `AssetId` にモデルの ID を指定します。ドラッグで回転でき、`Spin` で自動回転します。

## WebLink（リンク）

```lua
Tab:AddWebLink({
    Title = "UGeT",
    Url = "https://example.com",
    Description = "説明です",
})
```

URL のコピーと接続確認（Ping）ができます。

## Music（音楽）

専用のタブと、上部のプレイヤーバーが使えます。

```lua
Library.MusicPlayer.BuildTab(Window:AddTab("Music"))
```

Roblox の音声 ID はゲーム内で再生できます。Spotify / YouTube はブラウザで開きます（Roblox の仕様上、これらを直接ストリーム再生はできません）。「Show music bar」トグルでバーの表示を切り替えられます。

## 3D Animator（3D アニメーション）

```lua
Library.Animator3D.BuildTab(Window:AddTab("3D Animator"))
```

スライダーでポーズを作り、タイムラインにキーフレームを追加して再生します。ループ再生や JSON での書き出し/読み込みができます。

## Notifications（通知）

```lua
Library:Notify({
    Title = "UGeT",
    Text = "完了しました",
    Type = "success",
    Time = 4,
})
```

`Type` は `"info"` / `"success"` / `"warn"` / `"error"` です。`Time` は表示秒数です。通知は押すと消せます。

## Theme（テーマ）

```lua
Library.ThemeManager.BuildSection(Settings:AddSection("Theme"))
```

プリセットは UGeT / AMOLED / Graphite / Ocean / Sakura / Light の6種類です。アクセント色・背景色・文字色・フォントを自由に変更でき、その場で反映されます。

## Animations（アニメーション）

```lua
Library.Animations.BuildSettings(Settings:AddSection("Animations"))
```

Style は Smooth / Snappy / Spring / Bounce / Elastic / Cinematic / Linear の7種類です。Speed は 0.25倍〜2倍です。Animations トグルですべての動きを一括オン/オフでき、Play preview でその場で確認できます。

## Config（設定の保存）

```lua
Library.SaveManager:SetFolder("UGeT")
Library.SaveManager:BuildSection(Settings:AddSection("Config"))
```

すべてのコントロールの値を保存/読み込みできます。自動ロード（autoload）にも対応します。ファイル操作に対応した環境でのみ保存が使えます。

## 便利な機能

- **全体検索**: ヘッダーの虫眼鏡から、全タブのコントロールを検索してジャンプできます。
- **個別オン/オフ**: どのコントロールも無効化（半透明＋操作不可）できます。
- **依存関係**: 親のトグルがオンのときだけ子を有効にできます。
- **リセット**: 個別にも全体にも初期値へ戻せます。
- **キーバインド一覧**: 有効なキー割り当てを一覧表示できます。
- **コントロールマネージャー**: 任意のコントロールを選んで有効/無効/リセットできます。

これらは Settings にまとめられます。

```lua
Library.Enhance.BuildSettings(Settings:AddSection("Controls"))
```

依存関係の例:

```lua
Tab:AddToggle("parent", { Text = "親", Default = false })
Tab:AddToggle("child", { Text = "子", Default = false }):DependsOn("parent", true)
```

## フラグの操作

追加したコントロールは「フラグ」として後から操作できます。

```lua
Library.Flags["speed"]:SetValue(80)
Library.Flags["speed"]:GetValue()
Library.Flags["speed"]:SetEnabled(false)
Library.Flags["speed"]:Reset()
Library:SetEnabled("speed", false)
Library:ResetAll()
```

## ライブラリの主なメソッド

```lua
Library:CreateWindow({ Title = "UGeT" })
Library:Notify({ Text = "こんにちは" })
Library:Toggle()
Library:SetToggleKey("RightControl")
Library:GetFlag("speed")
Library:Fetch(url)
Library:OpenUrl(url)
Library:Destroy()
```

## スマートフォンでの表示

スマホではウィンドウが画面いっぱいに自動でフィットします。開閉ボタンは大きく右下に表示され、サイドバーのタブもタップしやすい高さになります。

## まとまった例

```lua
getgenv().UGET_NO_DEMO = true
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UGeT-UI-official/UI/main/UGeT.lua"))()
local Window = Library:CreateWindow({ Title = "UGeT" })
local Tab = Window:AddTab("Main")

Tab:AddButton("実行", function()
    Library:Notify({ Text = "実行しました", Type = "success" })
end)
Tab:AddToggle("on", { Text = "有効", Default = false, Callback = print })
Tab:AddSlider("speed", { Text = "スピード", Min = 0, Max = 100, Default = 50, Step = 5, Callback = print })
Tab:AddDropdown("mode", { Text = "モード", Values = { "A", "B" }, Default = 1, Callback = print })

local Settings = Window:AddTab("Settings")
Library.ThemeManager.BuildSection(Settings:AddSection("Theme"))
Library.Animations.BuildSettings(Settings:AddSection("Animations"))
Library.SaveManager:SetFolder("UGeT")
Library.SaveManager:BuildSection(Settings:AddSection("Config"))
```

## ライセンス

MIT です。
