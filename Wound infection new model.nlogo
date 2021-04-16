globals
[
  clock
  generations          ; a counter to keep track of the number of times the cells have divided
  number-of-cells      ; a counter used to keep track of the number of total cells in the world
  Migration-Probability
  Macrophage-Strength
  Neutrophil-Homing-Range
  ShowDebris
  Resistance
]

breed [bacteria bacterium]         ; this is the sub-category of turtles that are normal bacterial cells
breed [strongbacteria strongbacterium]         ; this is the sub-category of turtles that are a stronger strain of bacterial cells
breed [neutrophils neutrophil]    ; this is the first wave of immunes cells, they release anti-microbial cytokines and can also phagocytose bacteria
breed [macrophages macrophage]     ; this is the second wave of immune cells, the phagocytes that "clean up" debris and remove aged neutrophils

turtles-own [age]      ; a counter to keep track of turtles age after dividing (replaces "clock")
patches-own [
  debris               ; all dead cell become "debris" that must be removed to fully heal the wound
  wound                ; only a subset of patches are in the "Wound" and this represents where bacteria can enter from
]

to setup
  __clear-all-and-reset-ticks           ; clear all

  ask patch 0 0 [ask patches in-radius 15 [set wound 1 set pcolor red]]

  if Neutrophil_Response = "Low" [create-neutrophils ceiling (.1 * Immune-Cell-Infiltration)]
  if Neutrophil_Response = "Normal" [create-neutrophils ceiling (1 * Immune-Cell-Infiltration)]
  if Neutrophil_Response = "High" [create-neutrophils ceiling (2 * Immune-Cell-Infiltration)]

  ask neutrophils
    [
      setxy random-xcor random-ycor      ; randomize turtle locations to locations within the boundaries of the world
      setxy pycor pxcor                  ; place the turtles on the center of each patch
      set shape "neutrophil"            ; denote the shape of the turtle as an bacteria cell shape
      set age 1
    ]

    set Migration-Probability 70
    set Macrophage-Strength 3
    set Neutrophil-Homing-Range 1
    set ShowDebris true
end

to Run-Simulation
  proliferate-bacteria
  proliferate-strongbacteria
  proliferate-neutrophils
  proliferate-macrophages
  migrate
  Leukocyte-Actions

  if any? bacteria [
    if Neutrophil_Response = "Low" and ticks mod 3 = 0 [create-neutrophils ceiling (.1 * Immune-Cell-Infiltration) [setxy random-xcor random-ycor setxy pycor pxcor set shape "neutrophil" set age 1]]
    if Neutrophil_Response = "Normal" [create-neutrophils ceiling (1 * Immune-Cell-Infiltration)[setxy random-xcor random-ycor setxy pycor pxcor set shape "neutrophil" set age 1]]
    if Neutrophil_Response = "High" [create-neutrophils ceiling (2 * Immune-Cell-Infiltration) [setxy random-xcor random-ycor setxy pycor pxcor set shape "neutrophil" set age 1]]

  ]

  if any? strongbacteria [ ; Same as bacteria. We can change the recruitment of immune cells
    if Neutrophil_Response = "Low" and ticks mod 3 = 0 [create-neutrophils ceiling (.1 * Immune-Cell-Infiltration) [setxy random-xcor random-ycor setxy pycor pxcor set shape "neutrophil" set age 1]]
    if Neutrophil_Response = "Normal" [create-neutrophils ceiling (1 * Immune-Cell-Infiltration)[setxy random-xcor random-ycor setxy pycor pxcor set shape "neutrophil" set age 1]]
    if Neutrophil_Response = "High" [create-neutrophils ceiling (2 * Immune-Cell-Infiltration) [setxy random-xcor random-ycor setxy pycor pxcor set shape "neutrophil" set age 1]]

  ]

    if any? patches with [debris > 0 and ticks > 24] [
    if Macrophage_Response = "Low" and ticks mod 3 = 0 [create-macrophages ceiling (.1 * Immune-Cell-Infiltration) [setxy random-xcor random-ycor setxy pycor pxcor set shape "macrophage" set age 1]]
    if Macrophage_Response = "Normal" [create-macrophages ceiling (1 * Immune-Cell-Infiltration)[setxy random-xcor random-ycor setxy pycor pxcor set shape "macrophage" set age 1]]
    if Macrophage_Response = "High" [create-macrophages ceiling (2 * Immune-Cell-Infiltration) [setxy random-xcor random-ycor setxy pycor pxcor set shape "macrophage" set age 1]]

  ]

  ifelse ShowDebris                                 ;set patches to report debris by color
  [ask patches with [wound = 1 and debris > 0][set pcolor scale-color brown debris 0 4]]   ;scale patch color based on amount of debris
  [ask patches [set pcolor black]]
  ask patches with [wound = 1 and debris = 0][set pcolor red] ;reset patch color to red or black based on previous wound state
  ask patches with [wound = 0 and debris = 0][set pcolor black]


  ask neutrophils with [age > 48][if 100 * (age / 96) > random 100 [die ask patch-here [set debris debris + 1]]]
  ask macrophages with [age > 96][if 100 * (age / 192) > random 100 [die]]
  ask patches [if debris < 0 [set debris 0]]

  ask turtles [set age age + 1]
  set number-of-cells count bacteria           ; this counts the total number of bacteria cells, which is shown in the counter window below the main world.
  set clock clock + 1
  tick

end

to infect
  ask patch 0 0 [
    ask n-of Initial-Bacteria patches in-radius 15[
      sprout 1        ; create the number of initial bacteria as designated by the slider on the interface tab
      [
        set breed bacteria              ; denote the 'breed' of the turtle as an "bacteria" cell
        set shape "bacteria"            ; denote the shape of the turtle as an bacteria cell shape
        set age random prolif-rate
      ]
    ]
  ]

  ask patch 0 0 [
    ask n-of Initial-Strong-Bacteria patches in-radius 15[
      sprout 1        ; create the number of initial bacteria as designated by the slider on the interface tab
      [
        set breed strongbacteria              ; denote the 'breed' of the turtle as an "bacteria" cell
        set shape "bug"            ; denote the shape of the turtle as an bacteria cell shape
        set color green               ; denote thec olor of the turtle as green
        set age random prolif-rate
      ]
    ]
  ]
end

to proliferate-bacteria         ; this sub-routine simulates cell proliferation without any contact inhibition  [
  ask bacteria [
      if age mod prolif-rate = 0 and count bacteria-on neighbors + count strongbacteria-on neighbors < 8                 ; cell division happens for every cell at the same time (i.e. clock tick) according to the 'prolif-rate' set on the interface tab. See 'proliferate' sub-routine below.
      [
        hatch 1 [
          let attempted-moves  0
          while [any? other bacteria-here and any? other strongbacteria-here and attempted-moves < 16]
          [
            if not any? neighbors with [wound = 1 and not any? strongbacteria-here and not any? bacteria-here][die]
            move-to one-of neighbors with [wound = 1 and not any? strongbacteria-here and not any? bacteria-here]
            set attempted-moves attempted-moves + 1]

        ]
      ]
    ]
end

to proliferate-strongbacteria         ; this sub-routine simulates cell proliferation without any contact inhibition  [
  ask strongbacteria [
    if age mod prolif-rate = 0 and count bacteria-on neighbors + count strongbacteria-on neighbors < 8                 ; cell division happens for every cell at the same time (i.e. clock tick) according to the 'prolif-rate' set on the interface tab. See 'proliferate' sub-routine below.
      [
        hatch 1 [
          let attempted-moves  0
          while [any? other bacteria-here and any? other strongbacteria-here and attempted-moves < 16]
          [
            if not any? neighbors with [wound = 1 and not any? strongbacteria-here and not any? bacteria-here][die]
            move-to one-of neighbors with [wound = 1 and not any? strongbacteria-here and not any? bacteria-here]
            set attempted-moves attempted-moves + 1]

        ]
      ]
    ]
end

to proliferate-neutrophils                        ; this procedure simulates cell proliferation with contact inhibition for neutrophils
  ask neutrophils [
    if age mod 6 = 0 and age < 48 and count neutrophils-on neighbors = 0
      [
        hatch 1 [
          let attempted-moves  0
          while [any? other neutrophils-here and attempted-moves < 16]
          [
            move-to one-of neighbors with [not any? neutrophils-here]
            set attempted-moves attempted-moves + 1]

        ]
      ]
  ]

end

to proliferate-macrophages                       ; this procedure simulates cell proliferation with contact inhibition for macrophages
  ask macrophages [
    if age mod 15 = 0 and age < 48 and count macrophages-on neighbors = 0
      [
        hatch 1 [
          let attempted-moves  0
          while [any? other macrophages-here and attempted-moves < 16]
          [
            move-to one-of neighbors with [not any? macrophages-here]
            set attempted-moves attempted-moves + 1]

        ]
      ]
  ]

end

to migrate
  if random 100 <= migration-probability          ; migration is probabalistic based on a slider value
  [
    ask bacteria
    [
      if any? neighbors with [not any? bacteria-here and not any? strongbacteria-here and wound = 1]            ; migration only occurs if there is at least one empty neighboring patch
      [
        move-to one-of neighbors with [not any? bacteria-here and not any? strongbacteria-here] ; migrate to one of the 8 neighboring patches without a cell in it already
      ]
    ]

    ask strongbacteria
    [
      if any? neighbors with [not any? bacteria-here and not any? strongbacteria-here and wound = 1]            ; migration only occurs if there is at least one empty neighboring patch
      [
        move-to one-of neighbors with [not any? bacteria-here and not any? strongbacteria-here] ; migrate to one of the 8 neighboring patches without a cell in it already
      ]
    ]
  ]

  ask neutrophils ;neutrophils move towards bacteria in their homine range, or to a random neighboring patch
  [
    ifelse any? bacteria in-radius Neutrophil-Homing-Range [
      face min-one-of bacteria [distance myself]
      fd 1
    ]
    [move-to one-of neighbors]
  ]

  ask macrophages
  [
    ifelse any? bacteria-on neighbors or any? strongbacteria-on neighbors or any? neighbors with [debris > 0]
    [move-to one-of neighbors with [any? bacteria-here or any? strongbacteria-here or debris > 0]]
    [move-to one-of neighbors]
  ]
end

to Leukocyte-Actions
  ask neutrophils [if any? bacteria-on patch-here
    [
      ask patch-here [set debris debris + (count bacteria-here)]
      ask bacteria-on patch-here [die]
    ]
  ]

  ask neutrophils [if any? strongbacteria-on patch-here
    [
      if random 100 < Resistance[
        ask patch-here [set debris debris + (count strongbacteria-here)]
        ask strongbacteria-on patch-here [die]
      ]
    ]
  ]

  ask macrophages [if any? bacteria-on patch-here
    [ask bacteria-on patch-here [die]]
    if [debris] of patch-here > 0
    [ask patch-here [set debris debris - Macrophage-Strength]]
  ]

  ask macrophages [if any? strongbacteria-on patch-here [
    if random 100 < 30[
      ask bacteria-on patch-here [die]]
      if [debris] of patch-here > 0
      [ask patch-here [set debris debris - Macrophage-Strength]]
    ]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
623
10
1152
540
-1
-1
15.8
1
10
1
1
1
0
1
1
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

CHOOSER
82
250
237
295
Neutrophil_response
Neutrophil_response
"Low" "Normal" "High"
1

SLIDER
82
204
284
237
Immune-cell-infiltration
Immune-cell-infiltration
0
10
10.0
1
1
NIL
HORIZONTAL

CHOOSER
245
251
410
296
Macrophage_response
Macrophage_response
"Low" "Normal" "High"
1

SLIDER
81
103
253
136
Initial-bacteria
Initial-bacteria
0
100
50.0
1
1
NIL
HORIZONTAL

CHOOSER
82
146
254
191
Prolif-rate
Prolif-rate
2 4 6 8 12 24
0

BUTTON
81
10
147
43
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
13
10
70
55
Days
clock / 24
17
1
11

MONITOR
155
50
279
95
Number of Bacteria
count bacteria + count strongbacteria
1
1
11

TEXTBOX
264
156
506
207
Set the number of hours required for bacterial cell division
11
0.0
1

BUTTON
153
10
272
43
Run One Hour
Run-Simulation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
405
10
529
43
Run Until Clear
Run-Simulation\nif not any? turtles [stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
89
300
239
328
Set strength of neutrophil infiltration
11
84.0
1

BUTTON
279
10
398
43
Run One Week
repeat 168 [Run-Simulation]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
247
300
397
328
Strength of macrophage infiltration
11
113.0
1

TEXTBOX
292
206
535
244
Relative amount immune cells (neutrophils and macrophages) entering the wound
11
0.0
1

BUTTON
80
52
148
85
INFECT
infect
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
264
106
414
134
Number of bacteria that initially infect the wound
11
0.0
1

PLOT
85
336
416
493
Number of Cells
Hours
Cells
0.0
200.0
0.0
1000.0
true
true
"" ""
PENS
"Bacteria" 1.0 0 -4079321 true "" "plot count bacteria"
"Neutrophils" 1.0 0 -11221820 true "" "plot count neutrophils"
"Macrophages" 1.0 0 -10141563 true "" "plot count macrophages"
"Resistant Bacteria" 1.0 0 -5825686 true "" "plot count strongbacteria"

MONITOR
420
599
617
644
Percent of wound filled with debris
count patches with [pcolor > 29] / 709 * 100
17
1
11

PLOT
86
495
415
645
Percent of wound containing debris
NIL
NIL
0.0
200.0
0.0
100.0
true
false
"" ""
PENS
"debris" 1.0 0 -8431303 true "" "plot count patches with [pcolor > 29] / 709 * 100 \n"

SLIDER
400
107
572
140
Initial-strong-bacteria
Initial-strong-bacteria
0
100
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This is a simple model of wound healing with baterial infection. Bacteria (non-specific species) enter the wound area (red) upon infection and begin dividing. In response, neutrophils enter the wound to kill the bacteria. As the neutrophils age then undergo cell death and, combined with the dead bacteria, generate "inflammatory debris." At this stage, macrophages enter the area to clean up debris and serve as a second phagocyte to kill remaining bacteria.

Specific Neutrophil Behavior:
-Homing towards nearby bacteria
-Phagocytose and kill bacteria (generates 1 unit of inflammatory debris)
-Lifespan of 48 hours before they have a chance to undergo cell death (generates 1 unit of inflammatory debris)

Specific Macrophage Behavior:
-Homing to nearby patches with inflammatory debris OR bacteria
-Phagocytose and kill bacteria (no inflammatory debris)
-Remove inflammatory debris from patches
-Lifespan of 96 hours before they have a change to migrate out of the wound

The wound is "cleared" once all the bacteria are dead, all the inflammatory debris is removed, and all the immune cells have left the area.


## HOW TO USE IT

Explore the effects of inflammatory infiltration on the time it takes to recover from a wound infection. Begin by selecting the relative strength of the immune response:

-Select the number of leukocytes to begin the simulation with
-Select the strength of neutrophil infiltration (low, medium, high)
-Select the strength of macrophage infiltration (low, medium, high)

The "stronger" the response the more immune cells will arrive over time in respones to infection and inflammation.

Select the proliferation rate of the bacteria - by reducing the number of hours between proliferative cycles you will increase the rate of bacterial growth. For example, selecting "2" will cause bacteria to divide every two hours, the fastest rate available in this model. Also, select the number of initial bacteria you would like to being the infection - this determines the amount of bacteria that invade upon pressing the "INFECT" button.

To run the simulation, press "Get Started" to display the wound site in red and place the first wave of immune cells in the area. When ready to infect, press the "INFECT" button to have bacteria enter the wound. You can then run the simulation in three different ways:

1 Hour Intervals (one NetLogo "tick")
1 Week Intervals
"Until Clear" - run until the wound is free of bacteria, debris, or immune cells

Monitor the progress of healing by viewing the graph of each cell population and the graph of inflammatory debris. You can also see the current day of the simualation and the number of remaining bacteria in the output windows.
## THINGS TO NOTICE

The two main outputs from the model are the total population (shown in graphical from) and the actual model view. Observe changes to the shape of the population curve - rate of growth, stability, etc. - while also paying attention to the layout of cells in the "dish."

## THINGS TO TRY

Are there stable states? If so, how do you define "stable?"
Under what conditions does the wound never heal?
How does the infection change if the immune cells response is low, normal, or high?
What has the greatest effect on healing time?

## EXTENDING THE MODEL

A healing wound is a highly complex environment that we have chosen to model in a very simple manner. In particular, structural changes to the extracellular matrix would affect stiffness and in turn change the migratory behaviors of cells and bacteria. In cetain scenarios a wound may generate pockets of bacterial growth that the immune system simply cannot access, a potentially dangerous situation. A clear extension of the model would be to include more details in the construction of the wound itself.

There are many ways to add complexity to biological systems - extend the model based on the questions your seek to ask! 

## CREDITS AND REFERENCES

Joseph Walpole (2014)
MD/PhD Candidate
University of Virginia Medical Scientist Training Program
Department Biomedical Engineering
[Peirce-Cottler Laboratory]
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

bacteria
true
0
Circle -1184463 true false 90 105 90
Circle -1184463 true false 135 105 90
Circle -1184463 true false 63 108 85
Line -1184463 false 225 150 240 120
Line -1184463 false 240 120 270 165
Line -1184463 false 270 165 300 120
Polygon -1184463 true false 225 135 240 105 270 150 300 120 270 165 240 120

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

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

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

macrophage
false
4
Polygon -1 true false 30 210
Polygon -1 true false 29 212 21 194
Polygon -16777216 false false 36 197
Polygon -8630108 true false 285 105 210 0 90 0 0 105 15 210 90 300 210 300 300 210 150 150 285 105
Polygon -1 false false 90 0 0 105 15 210 90 300 210 300 300 210 150 150 285 105 210 0 90 0
Circle -1 true false 159 54 42

neutrophil
false
4
Circle -1 true false 30 30 240
Circle -11221820 true false 75 45 150

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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="example experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup
infect</setup>
    <go>run-simulation</go>
    <metric>count bacteria</metric>
    <metric>count neutrophils</metric>
    <metric>count macrophages</metric>
    <metric>count strongbacteria</metric>
    <metric>count patches with [pcolor &gt; 29] / 709 * 100</metric>
    <enumeratedValueSet variable="Macrophage_response">
      <value value="&quot;Normal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Immune-cell-infiltration">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Neutrophil_response">
      <value value="&quot;Normal&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Prolif-rate">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Initial-bacteria">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Initial-strong-bacteria">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
