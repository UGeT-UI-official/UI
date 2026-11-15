# UGeT

Roblox用の自作UIライブラリ。バージョンは **v1.0.0** で固定。中身は随時アップデートしていく。

## 読み込み

これ1行でいい:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/WaseranYaro8/UGeT-UI/main/UGeT.lua"))()
```

`UGeT.lua` は全部入りビルド。Core / Components / Addons を1ファイルにまとめてある。
何回実行しても前のインスタンスは自動で消えるから、二重起動の心配はない。

## できること

- サイドバー型ウィンドウ。ドラッグ / リサイズ / 最小化 / ピン留め。
- タブ、折りたたみセクション、全体検索。
- コントロールは全部個別にオンオフできる。依存関係（親がオンの時だけ有効）も組める。
- Button / Toggle / Slider(ステッパー付き) / Dropdown(検索・複数選択) / Input / ColorPicker / Keybind。
- アセットIDを貼ると画像・音声・動画・モデルを自動プレビュー。VideoFrame、3D Viewport。
- 音楽バー。Robloxの音声IDはゲーム内で再生。Spotify / YouTube はブラウザで開く。
- 3Dキーフレームアニメーター。
- テーマ6種（UGeT / AMOLED / Graphite / Ocean / Sakura / Light）+ 色・フォント自由変更。
- アニメーション設定。スタイル7種・速度・オンオフ・プレビュー。独自スプリング付き。
- 通知、設定の保存 / 読み込み / 自動ロード、キーバインド一覧パネル。
- PC / モバイル両対応。

## 構成

| ファイル | 役割 |
|---|---|
| Library.lua | 本体。モジュールの結線と公開API |
| Core/ | Window / Tab / Theme / Layout / Utility / Enhance |
| Components/ | 各コントロール（Button, Toggle, ... MusicPlayer, Animator3D） |
| Addons/ | 追加機能（Notifications, ThemeManager, SaveManager, Guide, Controls, Animations） |
| example.lua | そのまま動く使用例 |
| UGeT.lua | 公開用の全部入りビルド（配るのはこれ） |
| CHANGELOG.md | 更新履歴 |

## 使い方

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/WaseranYaro8/UGeT-UI/main/UGeT.lua"))()
local Window = Library:CreateWindow({ Title = "UGeT" })
local Tab = Window:AddTab("Main")
Tab:AddButton("Hello", function() print("UGeT") end)
Tab:AddToggle("my_toggle", { Text = "My toggle", Default = false, Callback = print })
Tab:AddSlider("my_slider", { Text = "Speed", Min = 0, Max = 100, Default = 50, Step = 5, Callback = print })
```

`example.lua` に動くサンプルがある。 built-in デモを消して自分のウィンドウだけ出したいときは、
読み込む前に `getgenv().UGET_NO_DEMO = true` を置く。

## アニメーション

Settings → Animations で切り替える。
Style は Smooth / Snappy / Spring / Bounce / Elastic / Cinematic / Linear。
Speed は 0.25x〜2x。Animations トグルで全部の動きを一括オンオフ。Play preview でその場で確認できる。

## 更新履歴

CHANGELOG.md に書いてある。バージョンは固定だけど、更新ごとに追記していく。

## ライセンス

MIT
