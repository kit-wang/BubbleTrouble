;; TNPG: Just Kind Kites
;; Members: Judy Chen, Kayla Tsui, Lin (Kitty) Wang

breed [ balls ball ]
breed [ cannons cannon ]
breed [ bubbles bubble ]

globals [
  lose?
  was-mouse-down?

  init_x
  init_y

  score

  the-tip ; the-tip and the-cannon are distinct to ease visuals
  the-cannon
  cannon-color

  self_color

]

balls-own [ done? bounced? ]

turtles-own [ should-pop? ]

to setup
  ca
  import-drawing "coralReefSquare.png"
  set score 0
  set lose? false
  set was-mouse-down? false
  set init_y 15.2
  set init_x -15.25
  ask bubbles [ set should-pop? false ]

  ;;the loops for the bubbles make the preset rows of circles at the top
  repeat 13 [
    create-bubbles 1 [
       initialize-spheres
       setxy init_x init_y
      ]
       set init_x init_x + 2.53
  ]
  set init_y init_y - 2.2
  set init_x -14

  repeat 12 [
    create-bubbles 1 [
       initialize-spheres
       setxy init_x init_y
      ]
       set init_x init_x + 2.53
  ]
  set init_y init_y - 2.2
  set init_x -15.25

  repeat 13 [
    create-bubbles 1 [
       initialize-spheres
       setxy init_x init_y
      ]
       set init_x init_x + 2.53
  ]
  set init_y init_y - 2.2
  set init_x -14

  repeat 12 [
    create-bubbles 1 [
       initialize-spheres
       setxy init_x init_y
      ]
       set init_x init_x + 2.53
  ]
  ;; this creates a two-piece cannon that rotates
  ;; around the second piece, or the circular base
  set cannon-color random-ball-color

  cro 1 [
    set ycor -14
    set shape "drop"
    set size 10
    set color cannon-color
    set the-tip self
  ]

  create-cannons 1 [
    set size 10
    set ycor -16
    set size 6
    set shape "circle"
    set heading 0
    set color cannon-color

    set the-cannon self

    create-link-to the-tip [ tie ]
;    ask link 2 1 [ set hidden? true ]
  ]
  ;; the init of the bubbles can def be optimized w a loop
end

;; update different parts of the game

to update-cannon
  ask the-cannon [
    let angle-of ( towardsxy mouse-xcor mouse-ycor )
    let max-angle (315)
    let min-angle (45)

    if angle-of > max-angle or angle-of < min-angle  [
      facexy mouse-xcor mouse-ycor
    ]
  ]
end

to update-balls
  ask balls [
   ifelse not done? [
      bounce
      fd 0.5

      set done? is-bubble-done?
   ]
   [
      pop
      count-pop
   ]
  ]
  check-loss

end

to update-mouse
  set was-mouse-down? mouse-down?
end

; events

to shoot-ball
  let start_x [xcor] of the-cannon
  let start_y [ycor] of the-cannon

  create-balls 1 [
    setxy start_x start_y
    set shape "circle"
    set heading [heading] of (the-cannon)
    set color ([color] of the-cannon)
    set size 2.5
    set done? false
    set self_color [color] of the-cannon
  ]

  ifelse (count bubbles > 5) [
    change-cannon-color random-ball-color ]
  [ change-cannon-color random-ball-color-2 ]

end

; helper functions

to-report random-ball-color
  report item random 6 [ 97 117 47 77 17 27 ]
end

to-report random-ball-color-2
  report [color] of one-of turtles ;;look over this
end

to initialize-spheres
  set shape "circle"
  set size 2.5
  set color random-ball-color
end

to change-cannon-color [ new-color ]
  ask the-cannon [ set color new-color ]
  ask the-tip [ set color new-color ]
end

to check-loss
  if count(balls with [done?] with [ycor < -9]) + count(balls with [bounced? = true] with [ycor < -9])> 0
  [ set lose? true ]
end

;; ensures that cannon balls ricochet off of the edges of the world

to bounce
  let future_patch patch-ahead 0.3
  if (future_patch != nobody)
  [
    if (abs [pxcor] of future_patch = max-pxcor)
    [ set heading (- heading) ]

    if ([pycor] of future_patch = max-pycor)
    [ set heading (180 - heading)
      set bounced? true
    ]
  ]

end

to-report is-bubble-done?
  report (any? bubbles in-radius 2.65) or (any? other balls in-radius 2.65)
end

to-report is-live?
  report (count bubbles + count balls) > 0
end

to-report should-shoot?
  report (mouse-down? and not was-mouse-down?)
end

;; main function

to play
  ifelse is-live? [
    update-cannon
    ask turtles [ set should-pop? false ]

    if should-shoot? [

      shoot-ball
    ]

    update-balls
    delete-frees
    if lose? = true [
    user-message ("Uh oh! The bubbles have taken over the coral reefs! Game Over")
    ca
    stop
    ]

    update-mouse

  ] [
    user-message ("Congrats!!! You have won the game and dissolved all of the bubbles!")
    ca
    stop
    ;; this will unpress the play button
  ]

  wait 0.01
end

;; the pop procedure is the rudimentary kill function called
;; when a ball is fired from the cannon

to pop
  if count(bubbles in-radius 2.65 with [color = self_color]) + count(balls in-radius 2.65 with [color = self_color]) > 1 [

    ask (bubbles in-radius 2.65 with [color = self_color] with [should-pop? = false]) [
      set should-pop? true
      pop
    ]
    ask (balls in-radius 2.65 with [color = self_color] with [should-pop? = false]) [
      set should-pop? true
      pop
    ]
  ]
end

to count-pop
  if count(turtles with [should-pop? = true]) > 1 + Difficulty
  [
    ask turtles with [should-pop? = true]
    [ set score score + 1
      die
    ]
  ]
end

;; delete-frees ensure that there are no lone bubbles/balls floating in the sea, and adds combo pops.
;; note that it is called after update-balls
to delete-frees
  ask balls with [done?] with [ycor < 15] [
      if count (turtles in-radius 2.7) < 2
      [ die ]
    ]
  ask bubbles with [ycor < 15] [
    if not any? other turtles in-radius 2.8 and should-pop? = false
      [ die ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
34
86
97
119
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
209
452
281
497
NIL
mouse-xcor
2
1
11

MONITOR
287
452
365
497
NIL
mouse-ycor
2
1
11

BUTTON
34
124
97
157
play
play\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
33
212
90
257
NIL
score
2
1
11

TEXTBOX
33
34
183
59
Bubble Trouble!
20
101.0
1

TEXTBOX
35
270
176
424
Click the setup button, then the play button to begin!\n\nEnjoy your view of the wonderful coral reefs and the adorable fish!\n\nThink strategically & earn combo pops to burst different colored bubbles at once!
11
0.0
1

SLIDER
33
170
205
203
Difficulty
Difficulty
1
3
1.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
TNPG: Just Kind Kites
Members: Judy Chen, Kayla Tsui, Lin (Kitty) Wang
Period 5

## WHAT IS IT?

Bubble Trouble is the Netlogo version of the 1990s arcade game, Puzzle Bobble. Similar to the original arcade game, Bubble Trouble primarily relies on color similarities in operation. The six different colors exhibited in this model are red, orange, yellow, green, blue, and violet. The instructions and objectives of the game are largely similar to the original. Bubble Trouble, as the name implies, is under-the-sea themed! 

We apologize to players who have colorblindness or bubble-phobia. 


## HOW IT WORKS

After a ball has been shot by a cannon at the lower half of the world, depending on the color of the ball, two options may occur. The first option includes the lack of destruction of any bubbles. If the bubble present in the patch at which the ball meets is not the same color as the ball, the ball will stop and stay at the furthest north point in the world, which may be defined by an obstruction: another bubble. The second option is induced by a contrasting condition. Secondly, if the bubble at the point at which the ball meets is the same color as the ball, the bubbles will only burst and disappear (forming a space) if there are at least three bubbles of the same color clustered at that area. They must be neighbors of each other. If there are not at least 3, the program refers back to the first option. If there are neighboring bubbles of a different color that are positioned lower than the chain of identical bubbles, then the bursting of the same-colored bubbles will also result in the bursting of the neighboring bubble(s) as a combo burst!


Your job is to make sure that the southmost bubble does not extend beyond the head of the cannon (save the corals!), by “popping” bubbles of a similar color in a timely fashion.

Note: The bubbles can be *very* stubborn, and may continue floating independently in the sea even if their neighbors have been dissolved! Make sure to burst them all!


## HOW TO USE IT

CANNON: Simply click your cursor after determining the perfect (or not-so-perfect) angle to aim, and watch the cannon fire the ball!

The user’s cursor should be in the vicinity of the Netlogo world. Moving the cursor left or right will dictate the cannon to move in a specific direction, and a left click of your mouse or trackpad will release the ball. Refer to the “HOW IT WORKS” section to determine the progression of your shot. 

PLAY: If the picturesque scenery before your eyes has impressed you, please press the play button to begin popping the bubbles.

SCORE: The score monitor reports, well... your score. For every bubble popped, your score will up by one point! Challenge your friends to see who resolves the bubble trouble the quickest!

DIFFICULTY: There are three levels in Bubble Trouble! The easiest and most straightforward option is 1, where only clustered three bubbles are required for a group to pop. As the difficulty increases, the bubbles become increasingly stubborn as the minimum number of bubbles required to pop a cluster increases. If you love to challenge yourself (or like to see the GAME OVER screen again and again), please try out the second and third levels!

## THINGS TO NOTICE

The cannon on the bottom shoots the bubbles, and is positioned based on the orientation of the mouse. Note that the current color of the cannon is also the color of the next bubble. The bubbles at the top are arranged in a pattern, so that the first row has the bubbles touching the left and right side of the world. The second row however, has black space on the left and right side, as the row of bubbles do not touch the left and right side of the world. This pattern continues for however many rows of bubbles there are. Also note the score monitor based on the amount of bubbles popped. 

With increased difficulty, parallel popping will be more prevalent as they interrupt your perfect plan, so expect the unexpected!

***IMPORTANT*** 

Again, these bubbles can be very stubborn at times, and even when their neighbors have been popped, they may persist and remain floating in the sea! Do not be deceived by their seemingly dull appearances! 

## THINGS TO TRY

“Blow” your friends away by beating your high score! As the game progresses, the difficulty increases, as the bubbles on the top will ascend down after each time interval. In order to prevent the bubbles from reaching the bottom of the world, the player must quickly aim the balls for the maximum amount of points. Observe the way the bubbles can bounce off the walls of the world, and use that to have better control over the trajectory of the bubble. 

However, beware of the double-edged sword that is the top edge of the world (or technically the sea surface)! You may use it to bounce the cannon ball and improve your gameplay, but a slight miss in aim may result in a devastating GAME OVER message.

## EXTENDING THE MODEL

There are six different bubble colors. The model could be extended by adding different point values to different colored bubbles, so that some bubbles are more valuable to pop first than others. The difficulty levels can also be modified for a harder challenge with the introduction of a timer or even more bubble colors.


## NETLOGO FEATURES

Note that the model uses the breed command. There is the ball breed, cannon breed, and bubble breed. The different breeds are used to differentiate between the various elements in the game to make the model run more smoothly (just like waves of the sea!). 

## RELATED MODELS

There is no current Netlogo program in the Models Library that is directly related to Bubble Trouble. However, this model would fit under the “Games” category, and is somewhat similar to the Pac-Man model (except Pac-Man doesn’t live in the ocean), in that both are based on older arcade versions of themselves. 

## CREDITS AND REFERENCES

No outside example from the Netlogo Model Library has been used, though class lessons and the NetLogo Dictonary have cleared up various confusions in the process of creating this game. This Netlogo Bubble Trouble is based on the 1990s arcade version of Bubble Trouble.

We must give a big thank you to Mr. DW for guiding us throughout sthis project, as well as to our parents for reluctantly serving as our game-testors. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bottle
true
0
Circle -7500403 true true 90 240 60
Rectangle -1 true false 135 8 165 31
Line -7500403 true 123 30 175 30
Circle -7500403 true true 150 240 60
Rectangle -7500403 true true 90 105 210 270
Rectangle -7500403 true true 120 270 180 300
Circle -7500403 true true 90 45 120
Rectangle -7500403 true true 135 27 165 51

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

cannon
true
0
Polygon -7500403 true true 165 0 165 15 180 150 195 165 195 180 180 195 165 225 135 225 120 195 105 180 105 165 120 150 135 15 135 0
Line -16777216 false 120 150 180 150
Line -16777216 false 120 195 180 195
Line -16777216 false 165 15 135 15
Polygon -16777216 false false 165 0 135 0 135 15 120 150 105 165 105 180 120 195 135 225 165 225 180 195 195 180 195 165 180 150 165 15

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

chess rook
false
0
Line -16777216 false 75 255 225 255
Polygon -7500403 true true 90 255 105 105 195 105 210 255
Polygon -16777216 false false 90 255 105 105 195 105 210 255
Rectangle -7500403 true true 75 90 120 60
Rectangle -7500403 true true 135 90 165 60
Rectangle -7500403 true true 180 90 225 60

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

drop
true
0
Circle -7500403 true true 73 133 152
Line -7500403 true 135 75 165 75
Circle -7500403 false true 75 135 150
Line -7500403 true 120 45 180 45
Polygon -7500403 true true 180 45 225 210 75 210 120 45 180 45

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
