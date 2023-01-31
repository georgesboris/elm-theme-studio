# elm-theme-studio

A tool to easily test and validate your [elm-theme](https://package.elm-lang.org/packages/uncover-co/elm-theme/latest) based themes.

    import Html
    import Theme
    import Theme.Studio


    type Model =
        { theme : Theme.Theme
        , themeStudioModel : Theme.Studio.Model
        }


    init : Model
    init =
        { theme = Theme.lightTheme
        , themeStudioModel = Theme.Studio.init Theme.lightTheme
        }


    type Msg
        = ThemeStudioMsg Theme.Studio.Msg


    update : Msg -> Model -> Model
    update msg model =
        case msg of
            ThemeStudioMsg themeStudioMsg ->
    	        let
                    themeStudioModel : Theme.Studio.Model
                    themeStudioModel =
                        Theme.Studio.update themeStudioMsg model.themeStudioModel

                    theme : Theme.Theme
                    theme =
                        Theme.Studio.toTheme themeStudioModel
                in
                { model
                    | theme = theme
                    , themeStudioModel = themeStudioModel
                    }


    view : Model -> Html.Html Msg
    view model =
        Theme.Studio.view model.themeStudioModel
            |> Html.map ThemeStudioMsg
