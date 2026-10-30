extends RefCounted

const CODES := ["en","fr","es","it","sv","nb","ar","tr","fa"]
const NAMES := ["English","Français","Español","Italiano","Svenska","Norsk","العربية","Türkçe","فارسی"]
static var locale := "en"
static var strings: Dictionary = {}
static var patterns: Array = []
static var ratio_regex: RegEx

static func initialize() -> void:
	if not strings.is_empty(): return
	strings = JSON.parse_string(FileAccess.get_file_as_string("res://assets/locales/strings.json"))
	var polish: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/locales/polish.json"))
	for key in polish:
		var translations: Dictionary={"en":key}
		for i in range(1,CODES.size()):translations[CODES[i]]=polish[key][i-1]
		strings[key]=translations
	ratio_regex = RegEx.new()
	ratio_regex.compile("[0-9]+\\s*/\\s*[0-9]+")
	for key in strings:
		if not (key.contains("%d") or key.contains("%s")): continue
		var expression := "^"
		var index := 0
		while index<key.length():
			if key.substr(index,2) in ["%d","%s"]:
				expression += "(-?[0-9]+)" if key.substr(index,2)=="%d" else "(.+?)"
				index += 2
			else:
				var ch: String = key[index]
				expression += "\\"+ch if ch in ["\\",".","+","*","?","(",")","[","]","{","}","^","$","|"] else ch
				index += 1
		var regex := RegEx.new()
		regex.compile(expression+"$")
		patterns.append({"key":key,"regex":regex})

static func set_locale(code: String) -> void:
	initialize()
	locale = code if code in CODES else "en"
	TranslationServer.set_locale(locale)

static func rtl() -> bool:
	return locale in ["fa","ar"]

static func t(value: String) -> String:
	if locale=="en": return value
	initialize()
	if strings.has(value): return direction_fix(str(strings[value].get(locale,value)))
	for item in patterns:
		var match_value: RegExMatch = item.regex.search(value)
		if not match_value: continue
		var result: String = strings[item.key].get(locale,item.key)
		for index in range(1,match_value.get_group_count()+1):
			var placeholder := result.find("%")
			if placeholder>=0: result = result.substr(0,placeholder)+t(match_value.get_string(index))+result.substr(placeholder+2)
		return direction_fix(result)
	return direction_fix(value)

static func direction_fix(value: String) -> String:
	if rtl() and value.contains("/") and not value.contains("\u2066"):
		value=ratio_regex.sub(value,"\u2066$0\u2069",true)
	return digits(value)

static func digits(value: String) -> String:
	if locale=="fa":
		for i in range(10):value=value.replace(str(i),"۰۱۲۳۴۵۶۷۸۹"[i])
	return value

static func style(control: Control) -> void:
	var original_position := control.position
	# Fixed board/UI coordinates must not mirror around zero-width UI roots.
	control.layout_direction = Control.LAYOUT_DIRECTION_LTR
	if control is Label or control is Button:
		control.text_direction = Control.TEXT_DIRECTION_RTL if rtl() else Control.TEXT_DIRECTION_AUTO
	if rtl(): control.add_theme_font_override("font",load("res://assets/fonts/Vazirmatn-Bold.ttf"))
	else: control.remove_theme_font_override("font")
	control.position = original_position

static func restyle_tree(node: Node) -> void:
	if node is Control: style(node)
	if (node is Label or node is Button) and node.has_meta("l10n_source"):
		node.text = t(str(node.get_meta("l10n_source")))
	for child in node.get_children(): restyle_tree(child)
	if node is Control and node.has_meta("l10n_x"): node.position.x = float(node.get_meta("l10n_x"))

static func restore_x(node: Node) -> void:
	if node is Control and node.has_meta("l10n_x"): node.position.x = float(node.get_meta("l10n_x"))
	for child in node.get_children(): restore_x(child)

static func fit_button(button: Button, width: float, base_size: int = 25) -> void:
	var font := button.get_theme_font("font")
	var font_size := base_size
	while font_size>16 and font.get_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>width-24:
		font_size -= 1
	button.add_theme_font_size_override("font_size",font_size)
	button.size.x = width
