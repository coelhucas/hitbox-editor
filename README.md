![](https://user-images.githubusercontent.com/28108272/90959201-de483b80-e46f-11ea-889d-6e227a7e4a0d.gif)

# Hitbox Editor v0.1.0

## Description
This is the first stable version to be used by everyone! Please relate any bug or feature request if so.

This project was started as a tool for a game I'm making with a friend, which needed a dedicated tool for handling collision boxes accordingly with our animation frames and give us a output to be used later in-game. It's mainly focused to be used with Godot Engine at the moment.

It work with animated `Scenes` from the [TSCN format](https://docs.godotengine.org/en/latest/development/file_formats/tscn.html).*

*You already can use your own `.TSCN` files, see the [Usage](#usage) section for details.

## ROADMAP
### Done
- [x] Total control of shape and position (Uses a rectangle shape)
- [x] Import collision shapes from another frame (in the same animation)
- [x] Define juggle and knockback parameters for your collision boxes
- [x] Use different types for your boxes to be handled in your game (hitbox, hurtbox, parry and taunt)
- [x] Inspector tools
- [x] Save and load made JSON files
- [x] Load external `.TSCN` files

### Upcoming
- [ ] Add/remove custom inspector variables to be saved and loaded with the json output
- [ ] Create and edit animations direcly on this tool, making it usable for other engines/frameworks users too.

### Known bugs
Nothing so far... Please open an issue if needed!

## Setup

Clone the repository from `git@github.com:coelhucas/hitbox-editor.git`
`git clone git@github.com:coelhucas/hitbox-editor.git`

Scan the project with Godot 3.2.1 + or [use the comand line](https://docs.godotengine.org/en/latest/getting_started/editor/command_line_tutorial.html) to [export the project](https://docs.godotengine.org/en/latest/getting_started/workflow/export/exporting_projects.html).

### Usage
You need to have a folder on the project's root called `Animated/` where your `.TSCN` files will be contained. The supported format is:
```
- An Node2D or derivative
  |_ AnimationPlayer # Currently the name must be AnimationPlayer, containing your animations

```

## License

```
Copyright 2020 Lucas Coelho

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

```
