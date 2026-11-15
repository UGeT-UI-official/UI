local Guide = {}
local Lib
Guide.Docs = {
	{ "UGeTについて", "Obsidian UIの良さを残しつつ、使いやすさを追求したUIライブラリ。スマホでも快適に使える。" },
	{ "ウィンドウ", "CreateWindow({Title, Width, Height})で作成。上のバーをドラッグで移動、右下でリサイズ。" },
	{ "ロック", "ヘッダーの「?」ボタンで位置とサイズを固定。もう一度押すと解除。" },
	{ "セクション", "AddSection(タイトル, 位置)でコントロールをグループ化。枠の上にタイトルが乗る。" },
	{ "トグル", "AddToggle(フラグ名, {Text, Default, Callback})。チェックボックス風。" },
	{ "スライダー", "AddSlider(フラグ名, {Text, Min, Max, Default, Step})。ドラッグで変更、値タップで数値入力。" },
	{ "ドロップダウン", "AddDropdown(フラグ名, {Text, Values, Multi})。複数選択も対応。" },
	{ "キーバインド", "AddKeybind(フラグ名, {Text, Default, Mode})。Toggle/Hold/Press。" },
	{ "色選択", "AddColorPicker(フラグ名, {Text, Default})。HSVで直感的に選べる。" },
	{ "通知", "Library:Notify({Text, Type, Time})。Type: info/success/warn/error。" },
}
function Guide.Init(l) Lib = l Lib.Guide = Guide Lib.Docs = Guide.Docs end
function Guide.BuildTab(tab)
	local start = tab:AddSection("はじめに")
	start:AddParagraph("ようこそ", "UGeTは、使いやすさを重視して作られたUIライブラリです。以下のタブから各機能を試せます。")
	start:AddButton({ Text = "通知テスト", Variant = "AccentColor", Func = function()
		Lib:Notify({ Title = "UGeT", Text = "通知はこんな感じで出ます", Type = "success" })
	end })
	local api = tab:AddSection("使い方", "Right")
	for _, row in ipairs(Guide.Docs) do api:AddParagraph(row[1], row[2]) end
	local tips = tab:AddSection("Tips")
	tips:AddLabel("スマホではサイドバーがアイコンだけになります。")
	tips:AddLabel("「?」ボタンでウィンドウをロックできます。")
	return tab
end
return Guide
