# Introduction to Algorithms and Data Structures - Public Transportation System - Final Project

## Description

The objective of this project was to create a system to manage routes of a public transportation system. <br>
We were to accomplish that purpose by created a sort of command-line interface (CLI) that would allow us to perform the necessary actions to manage such a system. <br>

| comand | action                                 |
|--------|----------------------------------------|
| q      | terminates the program                 |
| c      | add and list routes                    |
| p      | add and list stops                     |
| l      | add and list connections between stops |
| i      | list intersections between routes      |
| r      | removes a route                        |
| e      | removes a stop                         |
| a      | erases all current data                |

### Difference between versions

- **Version 1**: The first submission of the project. The system was supossed to only accept routes, stops and connections up until a limited amount. Commands were 'q','c','p','l' and 'i'.

- **Version 2**: The final submission of the project. The system was supossed to accept an unlimited amount of routes, stops and connections and allow deletion of these elements (enforcing the use dynamic memory). In case of the limit of memory being reached, the program should free all previous allocated memory and still end with EXIT_CODE 0. Additional commands were 'r','e' and 'a'.