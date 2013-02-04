//
//  NSMutableString+NewstepNSStringAdditions.m
//  Queens Lab QR Code Reader
//
//  Created by エルダ アンドレ on H.24/03/30.
//  Copyright (c) 平成24年 エルダ アンドレ. All rights reserved.
//

#import "NSMutableString+NewstepNSStringAdditions.h"
@interface NSMutableString (Mutability)
- (NSString *)mutableCopy;
+ (NSString *)string;
+ (NSString *)stringWithString:(NSString *)string;
+ (NSString *)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length;
+ (NSString *)stringWithUTF8String:(const char *)nullTerminatedCString;
+ (NSString *)stringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (NSString *)localizedStringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
@end


@implementation NSMutableString (NewstepNSStringAdditions)
- (void)replaceAllCharacters:(NSString *)characters withString:(NSString *)aString {
	if (self.length > 0) {
		[self replaceOccurrencesOfString:characters withString:aString options:0 range:NSMakeRange(0, self.length)];
	}
}

- (void)removeLastCharacter { 
	if (self.length > 0) {
		[self deleteCharactersInRange:NSMakeRange(self.length-1, 1)];
	}
}

- (void)removeFirstCharacter {
	if (self.length > 0) {
		[self deleteCharactersInRange:NSMakeRange(0, 1)];
	}
}

- (NSString *)immutableCopy { 
	if (self.length > 0) {
		return  [NSString stringWithFormat:@"%@",self];
	}
	
	return @"";
}

- (void)unCapitalizeString { 
	
	NSString *uncapitalizedString = self;
	
	if (self.length > 0) {
		NSString *substringToMakeLowercase = [[self substringToIndex:1] lowercaseString];
		NSString *remainingUppercasePartOfString = [self substringFromIndex:1];
		
		uncapitalizedString = [substringToMakeLowercase stringByAppendingString:remainingUppercasePartOfString];
	}
	
	[self setString:uncapitalizedString];
}


@end

@implementation NSString (NewstepNSStringAdditions)

- (NSString *)stringByRemovingLastCharacter {
	NSString *returnString = self;
	
	if (self.length > 0) {
		NSMutableString *mutableSelf = self.mutableCopy;
		[mutableSelf deleteCharactersInRange:NSMakeRange(self.length-1, 1)];
		returnString = mutableSelf.immutableCopy;
	}
	
	return returnString;
}

- (NSString *)stringByRemovingFirstCharacter {
	NSString *returnString = self;

	if (self.length > 0) {
		NSMutableString *mutableSelf = self.mutableCopy;
		[mutableSelf deleteCharactersInRange:NSMakeRange(0, 1)];
		returnString = mutableSelf.immutableCopy;
	}
	
	return returnString;
}



static const NSString *emojis =@"😄😃😀😊☺😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥✨🌟💫💥💢💦💧💤💨👂👀👃👅👄👍👎👌👊✊✌👋✋👐👆👇👉👈🙌🙏☝👏💪🚶🏃💃👫👪👬👭💏💑👯🙆🙅💁🙋💆💇💅👰🙎🙍🙇🎩👑👒👟👞👡👠👢👕👔👚👗🎽👖👘👙💼👜👝👛👓🎀🌂💄💛💙💜💚❤💔💗💓💕💖💞💘💌💋💍💎👤👥💬👣💭🐶🐺🐱🐭🐹🐰🐸🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩🐾💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌿🌾🍄🌵🌴🌲🌳🌰🌱🌼🌐🌞🌝🌚🌑🌒🌓🌔🌕🌖🌗🌘🌜🌛🌙🌍🌎🌏🌋🌌🌠⭐☀⛅☁⚡☔❄⛄🌀🌁🌈🌊🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🎋🎉🎊🎈🎌🔮🎥📷📹📼💿📀💽💾💻📱☎📞📟📠📡📺📻🔊🔉🔈🔇🔔🔕📢📣⏳⌛⏰⌚🔓🔒🔏🔐🔑🔎💡🔦🔆🔅🔌🔋🔍🛁🛀🚿🚽🔧🔩🔨🚪🚬💣🔫🔪💊💉💰💴💵💷💶💳💸📲📧📥📤✉📩📨📯📫📪📬📭📮📦📝📄📃📑📊📈📉📜📋📅📆📇📁📂✂📌📎✒✏📏📐📕📗📘📙📓📔📒📚📖🔖📛🔬🔭📰🎨🎬🎤🎧🎼🎵🎶🎹🎻🎺🎷🎸👾🎮🃏🎴🀄🎲🎯🏈🏀⚽⚾🎾🎱🏉🎳⛳🚵🚴🏁🏇🏆🎿🏂🏊🏄🎣☕🍵🍶🍼🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍎🍏🍊🍋🍒🍇🍉🍓🍑🍈🍌🍐🍍🍠🍆🍅🌽🏠🏡🏫🏢🏣🏥🏦🏪🏩🏨💒⛪🏬🏤🌇🌆🏯🏰⛺🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲🎢🚢⛵🚤🚣⚓🚀✈💺🚁🚂🚊🚉🚎🚆🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠🚧🔰⛽🏮🎰♨🗿🎪🎭📍🚩🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸🇫🇷🇪🇸🇮🇹🇷🇺🇬🇧🔟🔢#⃣🔣⬆⬇⬅➡🔠🔡🔤↗↖↘↙↔↕🔄◀▶🔼🔽↩↪ℹ⏪⏩⏫⏬⤵⤴🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🈯🈳🈵🈴🈲🉐🈹🈺🈶🈚🚻🚹🚺🚼🚾🚰🚮🅿♿🚭🈷🈸🈂Ⓜ🛂🛄🛅🛃🉑㊙㊗🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔✳❇❎✅✴💟🆚📳📴🅰🅱🆎🅾💠➿♻♈♉♊♋♌♍♎♏♐♑♒♓⛎🔯🏧💹💲💱©®™❌‼⁉❗❓❕❔⭕🔝🔚🔙🔛🔜🔃🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕡🕖🕢🕗🕣🕘🕤🕙🕥🕚🕦✖➕➖➗♠♥♣♦💮💯✔☑🔘🔗➰〰〽🔱◼◻◾◽▪▫🔺🔲🔳⚫⚪🔴🔵🔻⬜⬛🔶🔷🔸🔹";/*1⃣2⃣3⃣4⃣5⃣6⃣7⃣8⃣9⃣0⃣*/

static const NSString *utf8Emojis = @"☀☁☂☃☄★☆☇☈☉☊☋☌☍☎☏☐☑☒☓☔☕☖☗☘☙☚☛☜☝☞☟☠☡☢☣☤☥☦☧☨☩☪☫☬☭☮☯☰☱☲☳☴☵☶☷☸☹☺☻☼☽☾☿♀♁♂♃♄♅♆♇♈♉♊♋♌♍♎♏♐♑♒♓♔♕♖♗♘♙♚♛♜♝♞♟♠♡♢♣♤♥♦♧♨♩♪♫♬♭♮♯♰♱♲♳♴♵♶♷♸♹♺♻♼♽♾♿⚀⚁⚂⚃⚄⚅⚆⚇⚈⚉⚊⚋⚌⚍⚎⚏⚐⚑⚒⚓⚔⚕⚖⚗⚘⚙⚚⚛⚜⚝⚞⚟⚠⚡⚢⚣⚤⚥⚦⚧⚨⚩⚪⚫⚬⚭⚮⚯⚰⚱⚲⚳⚴⚵⚶⚷⚸⚹⚺⚻⚼⚽⚾⚿⛀⛁⛂⛃⛄⛅⛆⛇⛈⛉⛊⛋⛌⛍⛎⛏⛐⛑⛒⛓⛔⛕⛖⛗⛘⛙⛚⛛⛜⛝⛞⛟⛠⛡⛢⛣⛤⛥⛦⛧⛨⛩⛪⛫⛬⛭⛮⛯⛰⛱⛲⛳⛴⛵⛶⛷⛸⛹⛺⛻⛼⛽⛾⛿";

- (NSString *)unCapitalizedString { 
	
	NSString *uncapitalizedString = @"";
	
	if (self.length > 0) {
		NSString *substringToMakeLowercase = [[self substringToIndex:1] lowercaseString];
		NSString *remainingUppercasePartOfString = [self substringFromIndex:1];
		
		uncapitalizedString = [substringToMakeLowercase stringByAppendingString:remainingUppercasePartOfString];
	}
	
	return uncapitalizedString;
}

- (NSURL *)fileURL {
	return [NSURL fileURLWithPath:self];
}

- (NSURL *)url {
	return [NSURL URLWithString:self];
}

- (NSNumber *)number {
	NSNumberFormatter *formatterForProductNumber = [[NSNumberFormatter alloc] init];
	NSNumber *number = [formatterForProductNumber numberFromString:self];
	return number;
}

- (NSDate *)isoGMTDate {	
	NSDate *formattedDateString = [self isoDateWithTimeZoneAbbreviation:nil usingFormat:nil];
	return formattedDateString;
}

- (NSDate *)isoDateWithTimeZoneAbbreviation:(NSString *)timeZone usingFormat:(NSString *)format {
	NSLocale *enUSPosixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	NSDateFormatter *commaSeparatedDateFormatter = [[NSDateFormatter alloc] init];
	
	if (nil == timeZone) {
		commaSeparatedDateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
		commaSeparatedDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	} else {
		commaSeparatedDateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss zzz";
		commaSeparatedDateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:timeZone];
	}
	
	if (nil != format) {
		commaSeparatedDateFormatter.dateFormat = format;
	}
	
	commaSeparatedDateFormatter.locale = enUSPosixLocale;
	
	NSDate *formattedDateString = [commaSeparatedDateFormatter dateFromString:self];
	return formattedDateString;
}

- (NSString *)allEmojiCharacters {
	return (NSString *)emojis;
}

- (NSString *)utf8SafeEmojiCharacters {
	return (NSString *)utf8Emojis;
}

- (BOOL)isEmoji {
	BOOL isEmoji = NO;
	if ([self rangeOfCharacterFromSet:[NSCharacterSet emojiCharacterSet]].length > 0) {
		isEmoji = YES;
	}
	return isEmoji;
}

- (BOOL)isUTF16Emoji {
	BOOL isEmoji = NO;
	if ([self rangeOfCharacterFromSet:[NSCharacterSet utf16EmojiCharacterSet]].length > 0) {
		isEmoji = YES;
	}
	return isEmoji;
}

- (BOOL)isNotBlessedEnglish {
	NSArray *englishShit = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m",@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",@"Z",@"X",@"C",@"V",@"B",@"N",@"M",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"_",@"-",@".",@"\n",@"",@" "];
	
	BOOL foundShitEngishCharacter = NO;
	
	for (NSString *shitEnglishString in englishShit) {
		if ([self rangeOfString:shitEnglishString].length != 0 || [self isEqualToString:shitEnglishString]) {
			foundShitEngishCharacter = YES;
		}
	}
	
	return  !foundShitEngishCharacter;
}

- (BOOL)containsDiactric {
	NSArray *diactrics = @[@"À",@"Á",@"Â",@"Ã",@"Ä",@"Å",@"Æ",@"Ç",@"È",@"É",@"Ê",@"Ë",@"Ì",@"Í",@"Î",@"Ï",@"Ð",@"Ñ",@"Ò",@"Ó",@"Ô",@"Õ",@"Ö",@"×",@"Ø",@"Ù",@"Ú",@"Û",@"Ü",@"Ý",@"Þ",@"ß",@"à",@"á",@"â",@"ã",@"ä",@"å",@"æ",@"ç",@"è",@"é",@"ê",@"ë",@"ì",@"í",@"î",@"ï",@"ð",@"ñ",@"ò",@"ó",@"ô",@"õ",@"ö",@"÷",@"ø",@"ù",@"ú",@"û",@"ü",@"ý",@"þ",@"ÿ",@"A̧",@"a̧",@"Ç",@"ç",@"Ḉ",@"ḉ",@"Ḑ",@"ḑ",@"Ȩ",@"ȩ",@"Ḝ",@"ḝ",@"Ə̧",@"ə̧",@"Ɛ̧",@"ɛ̧",@"Ģ",@"ģ",@"Ḩ",@"ḩ",@"I̧",@"i̧",@"Ɨ̧",@"ɨ̧",@"Ķ",@"ķ",@"Ļ",@"ļ",@"M̧",@"m̧",@"Ņ",@"ņ",@"O̧",@"o̧",@"Ɔ̧",@"ɔ̧",@"Æ̧",@"æ̧",@"Œ̧",@"œ̧",@"Ŗ",@"ŗ",@"Ş",@"ş",@"Ţ",@"ţ",@"U̧",@"u̧",@"Z̧",@"z̧"];
	
	BOOL foundDiactric = NO;
	
	for (NSString *diactricString in diactrics) {
		if ([self rangeOfString:diactricString].length != 0 || [self isEqualToString:diactricString]) {
			foundDiactric = YES;
		}
	}
	
	return  foundDiactric;
}

@end



@implementation NSCharacterSet (EmojisAddition)

+ (NSCharacterSet*)emojiCharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:(NSString *)emojis];
}

+ (NSCharacterSet *)utf16EmojiCharacterSet {
	NSMutableCharacterSet *utf16OnlyCharacterSet = [NSMutableCharacterSet characterSetWithCharactersInString:(NSString *)emojis];
	[utf16OnlyCharacterSet removeCharactersInString:(NSString *)utf8Emojis];
	return utf16OnlyCharacterSet;
}

+ (NSCharacterSet*)utf8emojICharacterSet {
    return [NSCharacterSet characterSetWithCharactersInString:(NSString *)utf8Emojis];
}



@end