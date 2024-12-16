// This is eventually for wjohn to add more color standardization stuff like I keep asking him >:(


#define COLOR_DARKMODE_BACKGROUND		"#202020"
#define COLOR_DARKMODE_DARKBACKGROUND	"#171717"
#define COLOR_DARKMODE_TEXT				"#a4bad6"

#define COLOR_WHITE						"#FFFFFF"
#define COLOR_VERY_LIGHT_GRAY			"#EEEEEE"
#define COLOR_SILVER					"#C0C0C0"
#define COLOR_GRAY						"#808080"
#define COLOR_FLOORTILE_GRAY			"#8D8B8B"
#define COLOR_ALMOST_BLACK				"#333333"
#define COLOR_BLACK						"#000000"
#define COLOR_HALF_TRANSPARENT_BLACK    "#0000007A"

#define COLOR_RED						"#FF0000"
#define COLOR_MOSTLY_PURE_RED			"#FF3300"
#define COLOR_DARK_RED					"#A50824"
#define COLOR_RED_LIGHT					"#FF3333"
#define COLOR_MAROON					"#800000"
#define COLOR_VIVID_RED					"#FF3232"
#define COLOR_LIGHT_GRAYISH_RED			"#E4C7C5"
#define COLOR_SOFT_RED					"#FA8282"
#define COLOR_BUBBLEGUM_RED				"#950A0A"

#define COLOR_YELLOW					"#FFFF00"
#define COLOR_VIVID_YELLOW				"#FBFF23"
#define COLOR_VERY_SOFT_YELLOW			"#FAE48E"

#define COLOR_OLIVE						"#808000"
#define COLOR_VIBRANT_LIME				"#00FF00"
#define COLOR_LIME						"#32CD32"
#define COLOR_VERY_PALE_LIME_GREEN		"#DDFFD3"
#define COLOR_VERY_DARK_LIME_GREEN		"#003300"
#define COLOR_GREEN						"#008000"
#define COLOR_DARK_MODERATE_LIME_GREEN	"#44964A"

#define COLOR_CYAN						"#00FFFF"
#define COLOR_DARK_CYAN					"#00A2FF"
#define COLOR_TEAL						"#008080"
#define COLOR_BLUE						"#0000FF"
#define COLOR_BRIGHT_BLUE				"#2CB2E8"
#define COLOR_MODERATE_BLUE				"#555CC2"
#define COLOR_BLUE_LIGHT				"#33CCFF"
#define COLOR_NAVY						"#000080"
#define COLOR_BLUE_GRAY					"#75A2BB"

#define COLOR_PINK						"#FFC0CB"
#define COLOR_MOSTLY_PURE_PINK			"#E4005B"
#define COLOR_MAGENTA					"#FF00FF"
#define COLOR_STRONG_MAGENTA			"#B800B8"
#define COLOR_PURPLE					"#800080"
#define COLOR_VIOLET					"#B900F7"
#define COLOR_STRONG_VIOLET				"#6927c5"

#define COLOR_ORANGE					"#FF9900"
#define COLOR_TAN_ORANGE				"#FF7B00"
#define COLOR_BRIGHT_ORANGE				"#E2853D"
#define COLOR_LIGHT_ORANGE				"#ffc44d"
#define COLOR_PALE_ORANGE				"#FFBE9D"
#define COLOR_BEIGE						"#CEB689"
#define COLOR_DARK_ORANGE				"#C3630C"
#define COLOR_DARK_MODERATE_ORANGE		"#8B633B"

#define COLOR_BROWN						"#BA9F6D"
#define COLOR_DARK_BROWN				"#997C4F"

#define COLOR_GREEN_GRAY       "#99BB76"
#define COLOR_RED_GRAY         "#B4696A"
#define COLOR_PALE_BLUE_GRAY   "#98C5DF"
#define COLOR_PALE_GREEN_GRAY  "#B7D993"
#define COLOR_PALE_RED_GRAY    "#D59998"
#define COLOR_PALE_PURPLE_GRAY "#CBB1CA"
#define COLOR_PURPLE_GRAY      "#AE8CA8"

//Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK   "#545454"
#define COLOR_ASSEMBLY_BGRAY   "#9497AB"
#define COLOR_ASSEMBLY_WHITE   "#E2E2E2"
#define COLOR_ASSEMBLY_RED     "#CC4242"
#define COLOR_ASSEMBLY_ORANGE  "#E39751"
#define COLOR_ASSEMBLY_BEIGE   "#AF9366"
#define COLOR_ASSEMBLY_BROWN   "#97670E"
#define COLOR_ASSEMBLY_GOLD    "#AA9100"
#define COLOR_ASSEMBLY_YELLOW  "#CECA2B"
#define COLOR_ASSEMBLY_GURKHA  "#999875"
#define COLOR_ASSEMBLY_LGREEN  "#789876"
#define COLOR_ASSEMBLY_GREEN   "#44843C"
#define COLOR_ASSEMBLY_LBLUE   "#5D99BE"
#define COLOR_ASSEMBLY_BLUE    "#38559E"
#define COLOR_ASSEMBLY_PURPLE  "#6F6192"
#define COLOR_ASSEMBLY_PINK    "#ff4adc"

#define COLOR_INPUT_DISABLED "#F0F0F0"
#define COLOR_INPUT_ENABLED "#D3B5B5"

/proc/get_contrasting_color(colorhex1, colorhex2)
	// This proc will return the color that contrasts the most with
	// the average of the two colors.
	var/c_num_1 = hex2num(colorhex1) // returns a number between 0 and 16777215
	var/c_num_2 = hex2num(colorhex2) // returns a number between 0 and 16777215
	var/c_num_avg = max((c_num_1 + c_num_2) / 2, 1)
	var/c_num_contrast = max(16777215 - c_num_avg, 1) // the color that contrasts the most with the average of the two colors
	/// account for luminance and return a color that has a contrast ratio of at least 7:1
	var/con_ratio = 0
	if(c_num_avg > c_num_contrast)
		con_ratio = c_num_avg / c_num_contrast
	else
		con_ratio = c_num_contrast / c_num_avg
	var/tries = 100
	while(con_ratio < 7 && tries-- > 0)
		if(c_num_contrast <= 0) // we've reached the end of the color spectrum
			return "#000000" 
		else if(c_num_contrast >= 16777215) // we've reached the end of the color spectrum
			return "#FFFFFF"
		if(c_num_avg > c_num_contrast)
			c_num_contrast += 65535
		else
			c_num_contrast -= 65535
		con_ratio = c_num_avg / c_num_contrast
	var/hexcode = num2hex(c_num_contrast, 6)
	return "#[hexcode]"












