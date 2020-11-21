# Text-Adventure
A classic text adventure engine in Swift

## World definition
There are two ways of creating the world:
1. JSON file (recommended)
By the magic of Swift & Codable, you can simply define the world in a JSON file. (see defaultWorld.json for an example)
Caveat: if your JSON fails to parse correctly, the game will create a default world. You get a message in the console/debug area: "Loading of default world failed. Initiazing default world.". This is the only warning you get that something went wrong!

2. Programmatically
You can also create a constructor/factory that creates instances of World. 
* Add instances of type Room to the rooms array.
* Use connectRoomFrom(room: using direction: to room:) to connect rooms together.
* Add items to rooms using Room.addItem (note this returns a new room)
* Add doors by appending Door instances to world.doors.

## Lexer/Parser
The lexer translates the text input into a 'sentence'. I.e. it associates structure to the sentence, although it does not validate yet whether it's a valid command (that's up to the parser).

The text parsing is pretty rudimentary. It expects sentences of the form:
* [VERB] or 
* [VERB] [NOUN]
* [VERB] [NOUN] [RELATIONSHIP] [ANOTHER NOUN]

A `Sentence` is basically an enum with associated values for the sentence parts where applicatible. The following sentence cases are possibles:
* empty: the input was empty
* illegal: it was not possible to transform the input text to any sentence
* no noun: a sentence consisting of just a verb. I.e. 'LOOK';
* one noun: a sentence with a verb and a noun. I.e. 'TAKE' (verb) 'Skeleton Key' (noun);
* two nouns: a sentence with a very, a noun, a relation and another noun. I.e. 'COMBINE' (verb) 'Empty lamp' (first noun) 'WITH' (relation) 'Fuel' (second noun).

The lexer also contains some abbreviations and synonims for common commands. I.e. input `n` is translated to `GO NORTH` (available for all four directions). `GET` is translated to `TAKE`. 

The parser has some 'fuzzy logic' to help players make sense of commands. It does this by trying to match input to reasonable nouns as much as possible.
For instance, in a room with one Skeleton Key, all of the following commands pick up the key:
* TAKE Skeleton Key
* TAKE Key
* TAKE Skeleton
* TAKE ton

Note: if you have two items in a room, both starting with the word "Green", then you can't pick any up. So be careful.

## Formatter
The project contains two formatters (conforming to `Formatter` protocol)
1. AttributedTextFormatter: outputs `NSAttributedString` (for use in AppKit based solutions)
2. SwiftUIFormatter: outputs SwiftUI `Text` values.

The game currently uses the SwiftUIFormatter.

### AttributedTextFormatter
The formatter is based on `NSAttributedString` feature to parse HTML files. To do so, we parse an HTML template (`view/template.html`) and embed the strings to format in an string storing HTML. Some custom tags such as `<ITEM></ITEM>` are used to add inline styling to the returned results.

### SwiftUIFormatter
The formatter parses the provided HTML like text into `TextElement`s (a tree of formatted strings). Then the tree is flattened into an array of `[TextElement]`. Finally, the formatter converts the flattened array into a new SwiftUI `Text` value.

## Notes
* This project now targets macOS 11 to support the following new SwiftUI features:
    * SwiftUI Lifecycle (i.e. `@main`)
    * Keyboard shortcuts (no enter to send the command)
    * Automatic scroll to the end of the scrollview.
* Known issues: 
    * SwiftUI has no way to automatically focus a control. In particular, I want the command field to have focus after starting the program so you can just start typing away. I'm currently deciding whether to use a workaround or simply wait for this (obvious) functionality to be shipped by Apple. 