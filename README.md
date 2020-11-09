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
The lexer translates the sentence in words (seperated by spaces).
A sentance like:
* TAKE Skeleton Key is lexed to "TAKE", "Skeleton", "Key".

The text parsing is pretty rudimentary. It expects sentences of the form:
* [VERB] or 
* [VERB] [NOUN]

However, take the Skeleton Key from above as an example. Currently the only word passed to the "TAKE" command is the first word after the verb, i.e. "Skeleton". This doesn't matter because the parser tries to make sense of partial words as much as possible. 

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
