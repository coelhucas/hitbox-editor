# Usage

## Setup

At the moment the tool works only with pre-created `.TSCN` files from Godot. The format of the file should be:

```
├── Main Node
│   ├── AnimationPlayer
├── (...Rest)
```

The tool only cares about the main node and an `AnimationPlayer` being directly child of it. All the animations will be imported automagically when you setup your `.TSCN` in the `Animated/` folder.
You can see that there's also an example file to help you understand how this setup is made.

## Editing

From this point, you can select the desired animation to be worked on at the second selector at the topbar:


![image](https://user-images.githubusercontent.com/28108272/90959881-05a10780-e474-11ea-89db-69295789c21e.png)

With the arrow keys, you can go to the next or previous frame in the animation.
To add your first hitbox, press A or go to `Box -> New (A)`. From there you can move it, scale with the anchor points and change its type to one of the pre-defined ones (Hitbox/Hurtbox/Parry/Taunt).
You can also define parameters to a specific hitbox, such as *juggle* and *knockback* [1].

[1] An upcoming feature is to dynamically create your custom parameters to avoid this limitation of just two.

## Output

After editing your boxes, you can preview it with P or pressing "Play". With `CTRL+S` or `File -> Save (CTRL + S)` you can save the output JSON file which can be later opened by the tool. This JSON has the following format:
```json
{
   "idle":{
      "0":[

      ]
   },
   "punch":{
      "0":[

      ],
      "1":[

      ],
      "2":[
         {
            "dimensions":{
               "x":20,
               "y":10
            },
            "juggle":13,
            "knockback":0,
            "position":{
               "x":27,
               "y":15
            },
            "type":"hitbox"
         },
         {
            "dimensions":{
               "x":20,
               "y":20
            },
            "juggle":0,
            "knockback":0,
            "position":{
               "x":0,
               "y":0
            },
            "type":"hurtbox"
         }
      ]
   }
}
```

Each primary key represents an animation name, and the parameters are mostly self explanatory.
`0, 1, 2, ...` (keys) -> represents each frame of an animation;
`dimensions` -> an object containing the horizontal and vertical sizes of the box;
`position` -> an object containing the position of the box center;
`juggle`, `knockback` -> parameter values;
`type` -> box type (hitbox, hurtbox, and so on).

With this data you can make a simple parser in any engine/framework to handle and generate this data dynamically in your fight/beat'em up game, for instance.

## Shortcuts Cheatsheet
- `A` -> creates a new box;
- `Z` -> deletes the selected box;
- `CTRL+O` -> opens a tool generated file (in JSON format);
- `CTRL+I` -> imports a tool generated file (in JSON format)*;
- `CTRL+S` -> saves a tool generated file (in JSON format);
- `SHIFT+I` -> import frames of another frame;
- `I` -> opens the inspector;
- `Left/Right arrows` -> prev/next frame;
- `P/S` -> plays/stops the current animation.

*- Instead of replacing your current boxes, it "append" them to the imported ones.

Feel free to suggest changes and new shortcuts [here](https://github.com/coelhucas/hitbox-editor/issues).

This usage section will be modified and improved, but I hope this helps for now.
