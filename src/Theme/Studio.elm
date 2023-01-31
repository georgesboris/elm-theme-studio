module Theme.Studio exposing
    ( Model, Msg
    , init, toTheme
    , update
    , view
    )

{-| Please see the [README](https://package.elm-lang.org/packages/uncover-co/elm-theme-studio/latest) for a complete example.

@docs Model, Msg
@docs init, toTheme
@docs update
@docs view

-}

import Color
import Html as H
import SolidColor
import SolidColor.Accessibility
import Theme
import W.Badge
import W.Container
import W.Divider
import W.Heading
import W.InputColor
import W.Styles
import W.Text


{-| -}
type Model
    = Model
        { theme : Theme.Theme
        }


{-| -}
init : Theme.Theme -> Model
init theme =
    Model
        { theme = theme
        }


{-| -}
toTheme : Model -> Theme.Theme
toTheme (Model model) =
    model.theme


{-| -}
type Msg
    = DoNothing
    | Update ThemeColor ThemeColorDetail Color.Color


type ThemeColor
    = Base
    | Primary
    | Secondary
    | Neutral
    | Success
    | Danger
    | Warning


themeColorLabel : ThemeColor -> String
themeColorLabel themeColor =
    case themeColor of
        Base ->
            "Base"

        Primary ->
            "Primary"

        Secondary ->
            "Secondary"

        Neutral ->
            "Neutral"

        Success ->
            "Success"

        Danger ->
            "Danger"

        Warning ->
            "Warning"


type ThemeColorDetail
    = Background
    | Foreground
    | Aux


themeColorDetailLabel : ThemeColorDetail -> String
themeColorDetailLabel value =
    case value of
        Background ->
            "Background"

        Foreground ->
            "Foreground"

        Aux ->
            "Aux"


{-| -}
update : Msg -> Model -> Model
update msg (Model model) =
    case msg of
        DoNothing ->
            Model model

        Update color detail value ->
            let
                themeData : Theme.ThemeData
                themeData =
                    Theme.toThemeData model.theme

                newThemeData : Theme.ThemeData
                newThemeData =
                    case color of
                        Base ->
                            { themeData | base = updateColor themeData.base detail value }

                        Primary ->
                            { themeData | primary = updateColor themeData.primary detail value }

                        Secondary ->
                            { themeData | secondary = updateColor themeData.secondary detail value }

                        Neutral ->
                            { themeData | neutral = updateColor themeData.neutral detail value }

                        Success ->
                            { themeData | success = updateColor themeData.success detail value }

                        Danger ->
                            { themeData | danger = updateColor themeData.danger detail value }

                        Warning ->
                            { themeData | warning = updateColor themeData.warning detail value }
            in
            Model { theme = Theme.new newThemeData }


updateColor : Theme.ThemeColorSet -> ThemeColorDetail -> Color.Color -> Theme.ThemeColorSet
updateColor colorSet detail value =
    case detail of
        Background ->
            { colorSet | background = value }

        Foreground ->
            { colorSet | foreground = value }

        Aux ->
            { colorSet | aux = value }


{-| -}
view : Model -> H.Html Msg
view (Model model) =
    let
        theme : Theme.Theme
        theme =
            model.theme

        themeData : Theme.ThemeData
        themeData =
            Theme.toThemeData model.theme

        baseBg : SolidColor.SolidColor
        baseBg =
            toSolidColor themeData.base.background
    in
    Theme.provider theme
        []
        [ W.Styles.globalStyles
        , W.Container.view
            [ W.Container.pad_4
            , W.Container.background ("linear-gradient(rgba(0,0,0,0.1), rgba(0,0,0,0.1)), " ++ Theme.baseBackground)
            ]
            [ W.Container.view
                [ W.Container.rounded
                , W.Container.background Theme.baseBackground
                , W.Container.shadow
                ]
                (colorSelector baseBg
                    Update
                    ( Base, themeData.base, Theme.base )
                    [ W.Text.view [] [ H.text "This is the default text color." ]
                    , W.Text.view [ W.Text.aux ] [ H.text "And this is the auxiliary text color." ]
                    ]
                    :: ([ ( Neutral, themeData.neutral, Theme.neutral )
                        , ( Primary, themeData.primary, Theme.primary )
                        , ( Secondary, themeData.secondary, Theme.secondary )
                        , ( Success, themeData.success, Theme.success )
                        , ( Warning, themeData.warning, Theme.warning )
                        , ( Danger, themeData.danger, Theme.danger )
                        ]
                            |> List.map
                                (\( a, b, c ) ->
                                    H.div
                                        []
                                        [ W.Divider.view [ W.Divider.light ] []
                                        , colorSelector baseBg
                                            Update
                                            ( a, b, c )
                                            [ W.Container.view
                                                [ W.Container.gap_2
                                                , W.Container.padTop_2
                                                ]
                                                [ W.Container.view
                                                    [ W.Container.background c.background
                                                    , W.Container.padX_4
                                                    , W.Container.padY_2
                                                    , W.Container.extraRounded
                                                    ]
                                                    [ W.Text.view
                                                        [ W.Text.color c.aux ]
                                                        [ H.text "Aux on background" ]
                                                    ]
                                                , W.Container.view
                                                    [ W.Container.background (c.foregroundWithAlpha 0.05)
                                                    , W.Container.padX_4
                                                    , W.Container.padY_2
                                                    , W.Container.extraRounded
                                                    ]
                                                    [ W.Text.view
                                                        [ W.Text.color c.foreground ]
                                                        [ H.text "Foreground on tinted base background" ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                )
                       )
                )
            ]
        ]


input : SolidColor.SolidColor -> SolidColor.SolidColor -> (ThemeColorDetail -> Color.Color -> Msg) -> ThemeColorDetail -> H.Html Msg
input color contrastColor msg themeColorDetail =
    W.Container.view []
        [ W.Container.view
            [ W.Container.padBottom_1
            , W.Container.alignLeft
            , W.Container.horizontal
            , W.Container.gap_1
            ]
            [ W.Text.view
                [ W.Text.small, W.Text.semibold ]
                [ H.text (themeColorDetailLabel themeColorDetail) ]
            , contrast color contrastColor
            , a11yStatus color contrastColor
            ]
        , W.Container.view
            [ W.Container.background (Theme.baseForegroundWithAlpha 0.07)
            , W.Container.padX_3
            , W.Container.padY_2
            , W.Container.gap_2
            , W.Container.rounded
            , W.Container.alignRight
            , W.Container.horizontal
            ]
            [ H.div []
                [ W.Text.view [ W.Text.small, W.Text.alignRight ] [ H.text (SolidColor.toHex color) ]
                , W.Text.view [ W.Text.small, W.Text.alignRight ] [ H.text (SolidColor.toRGBString color) ]
                ]
            , W.InputColor.view []
                { value = fromSolidColor color
                , onInput = msg themeColorDetail
                }
            ]
        ]


a11yStatus : SolidColor.SolidColor -> SolidColor.SolidColor -> H.Html msg
a11yStatus fg bg =
    case SolidColor.Accessibility.checkContrast { fontSize = 12, fontWeight = 500 } fg bg of
        SolidColor.Accessibility.Inaccessible ->
            H.text ""

        SolidColor.Accessibility.AA ->
            W.Badge.viewInline [ W.Badge.small, W.Badge.neutral ] [ H.text "AA" ]

        SolidColor.Accessibility.AAA ->
            W.Badge.viewInline [ W.Badge.small, W.Badge.success ] [ H.text "AAA" ]


contrast : SolidColor.SolidColor -> SolidColor.SolidColor -> H.Html msg
contrast c1 c2 =
    SolidColor.Accessibility.contrast c1 c2
        |> String.fromFloat
        |> String.split "."
        |> (\xs ->
                case xs of
                    [] ->
                        ""

                    [ h, t ] ->
                        h ++ "." ++ String.left 2 t

                    h :: _ ->
                        h
           )
        |> (\str ->
                W.Text.view
                    [ W.Text.extraSmall, W.Text.aux ]
                    [ H.text str ]
           )


colorSelector : SolidColor.SolidColor -> (ThemeColor -> ThemeColorDetail -> Color.Color -> Msg) -> ( ThemeColor, Theme.ThemeColorSet, Theme.ThemeColorSetValues ) -> List (H.Html Msg) -> H.Html Msg
colorSelector baseBg msg ( themeColor, color_, color ) children =
    let
        bg : SolidColor.SolidColor
        bg =
            toSolidColor color_.background

        fg : SolidColor.SolidColor
        fg =
            toSolidColor color_.foreground

        aux : SolidColor.SolidColor
        aux =
            toSolidColor color_.aux
    in
    W.Container.view
        [ W.Container.node "section"
        , W.Container.vertical
        , W.Container.spaceBetween
        , W.Container.padX_4
        , W.Container.padY_8
        , W.Container.gap_4
        ]
        [ W.Container.view
            [ W.Container.fill ]
            [ W.Heading.view
                [ W.Heading.extraSmall, W.Heading.color (SolidColor.toHex fg) ]
                [ H.text (themeColorLabel themeColor) ]
            , H.div [] children
            ]
        , W.Container.view
            [ W.Container.horizontal
            , W.Container.gap_2
            , W.Container.pad_2
            , W.Container.card
            ]
            [ input fg baseBg (msg themeColor) Foreground
            , input bg aux (msg themeColor) Background
            , input aux bg (msg themeColor) Aux
            ]
        ]



-- Helpers


toSolidColor : Color.Color -> SolidColor.SolidColor
toSolidColor color =
    color
        |> Color.toRgba
        |> (\{ red, green, blue } -> ( red * 255, green * 255, blue * 255 ))
        |> SolidColor.fromRGB


fromSolidColor : SolidColor.SolidColor -> Color.Color
fromSolidColor color =
    color
        |> SolidColor.toRGB
        |> (\( r, g, b ) -> Color.rgb255 (floor r) (floor g) (floor b))
