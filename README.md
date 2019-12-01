![](https://github.com/coelhucas/hitbox-editor/blob/master/Screenshots/Screen%20Shot%202019-11-25%20at%2012.53.29.png?raw=true)

# Hitbox Editor v0.1.0

## Description
This is the first stable version to be used by everyone! Please relate any bug or feature request if so.

This project was started as a tool for a game I'm making with a friend, which needed a dedicated tool for handling collision boxes accordingly with our animation frames and give us a output to be used later in-game. It's mainly focused to be used with Godot Engine at the moment.

It work with animated `Scenes` from the [TSCN format](https://docs.godotengine.org/en/3.1/development/file_formats/tscn.html).*

*You already can use your own `.TSCN` files, see the [Usage](#usage) section for details.

## Features
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
- [ ] Flexibilize supported `.TSCN` file

### Known bugs
Nothing so far... Please open an issue if needed!

## Setup

Clone the repository from `git@github.com:coelhucas/hitbox-editor.git`
`git clone git@github.com:coelhucas/hitbox-editor.git`

Scan the project with Godot 3.1 + or [use the comand line](https://docs.godotengine.org/en/3.1/getting_started/editor/command_line_tutorial.html) to [export the project](https://docs.godotengine.org/en/3.1/getting_started/workflow/export/exporting_projects.html).

### Usage
You need to have a folder on the project's root called `Animated/` where your `.TSCN` files will be contained. The supported format is:
```
- An Node2D or derivative
  |_ AnimationPlayer # Currently the name must be AnimationPlayer, containing your animations

```

And you're ready to go!
