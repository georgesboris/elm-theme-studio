module Main exposing (main)

import ElmBook exposing (Book, book, withStatefulOptions, withComponentOptions, withChapters)
import ElmBook.Actions
import ElmBook.Chapter exposing (chapter, renderStatefulComponent)
import ElmBook.ComponentOptions
import ElmBook.StatefulOptions
import Html as H
import Theme
import Theme.Studio


main : Book Theme.Studio.Model
main =
    book "elm-theme-studio"
        |> withStatefulOptions
            [ ElmBook.StatefulOptions.initialState
                (Theme.Studio.init Theme.lightTheme)
            ]
        |> withComponentOptions
            [ ElmBook.ComponentOptions.fullWidth True
            ]
        |> withChapters
            [ chapter "Theme Studio"
                |> renderStatefulComponent
                    (\state ->
                        Theme.Studio.view state
                            |> H.map
                                (ElmBook.Actions.mapUpdate
                                    { toState = \_ -> identity
                                    , fromState = identity
                                    , update = Theme.Studio.update
                                    }
                                )
                    )
            ]
