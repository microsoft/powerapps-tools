using PowerApps_Theme_Editor.Model;
using System;
using System.Collections.Generic;

namespace PowerApps_Theme_Editor.Design
{
    public class DesignDataService : IDataService
    {
        public void GetData(string path, Action<ThemeModel, Exception> callback)
        {
            ThemeModel item = new ThemeModel()
            {
                palette = new List<Palette>() {
                    new Palette()
                    {
                        name = "ScreenBkgColor",
                        value = "RGBA(255, 255, 255, 1)",
                        type =  "c"
                    },
                    new Palette()
                    {
                        name = "InnerCircleBkgColor",
                        value = "RGBA(255, 255, 255, 1)",
                        type =  "c"
                    },
                    new Palette()
                    {
                        name = "TextMainColor",
                        value = "RGBA(30, 30, 30, 1)",
                        type =  "c"
                    },
                     new Palette()
                    {
                        name = "TextMainColorInverted",
                        value = "RGBA(255, 255, 255, 1)",
                        type =  "c"
                    },
                    new Palette()
                    {
                        name = "PrimaryColor1",
                        value = "RGBA(0, 128, 137, 1)",
                        type =  "c"
                    },
                    new Palette()
                    {
                        name = "PrimaryColor4",
                        value = "RGBA(200, 200, 200, 1)",
                        type =  "c"
                    },
                    new Palette()
                    {
                        name = "PrimaryColor6",
                        value = "RGBA(102, 102, 102, 1)",
                        type =  "c"
                    },
                    new Palette()
                    {
                        name = "PrimaryColor7",
                        value = "RGBA(102, 102, 102, 1)",
                        type =  "c"
                    },
                    new Palette()
                    {
                        name = "TextColor1",
                        value = "RGBA(102, 102, 102, 1)",
                        type =  "c"
                    },
                   new Palette()
                    {
                        name = "TextColor2",
                        value = "RGBA(51, 51, 51, 1)",
                        type =  "c"
                    },
                    new Palette()
                    {
                        name = "ReservedWhiteColor",
                        value = "RGBA(255, 255, 255, 1)",
                        type =  "c"
                    },
                   new Palette()
                    {
                        name = "InvertedBkgColor",
                        value = "RGBA(12, 123, 120, 1)",
                        type =  "c"
                    },
                   new Palette()
                   {
                      name= "InputFocusedBorderThickness",
                      value= "4",
                      type= "n"
                   },
                   new Palette()
                   {
                      name= "defaultRadius",
                      value= "5",
                      type= "n"
                   },
                    new Palette()
                   {
                      name= "InputBorderThickness",
                      value= "1",
                      type= "n"
                   },
                   new Palette()
                   {
                       name="TextBodyFontFace",
                       value ="%Font.RESERVED%.Lato",
                       type="e"
                   } ,
                  new Palette()
                   {
                       name="TextEmphasisFontWeight",
                       value ="%FontWeight.RESERVED%.Bold",
                       type="e"
                   },
                   new Palette()
                   {
                       name="DefaultBorderStyle",
                       value ="%BorderStyle.RESERVED%.Solid",
                       type="e"
                   },
                   new Palette()
                   {
                       name="TextEmphasisFontSize",
                       value= "15",
                       phoneValue="24",
                       type= "n"
                   }
                },
                styles = new List<Style>
                {
                    new Style()
                    {
                        name = "defaultScreenStyle",
                        controlTemplateName = "screen",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "Fill",
                                value = "%Palette.ScreenBkgColor%"
                            }
                        }
                    }
                    ,
                    new Style()
                    {
                        name = "defaultDatePickerStyle",
                        controlTemplateName = "Button",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "IconFill",
                                value = "%Palette.ReservedWhiteColor%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "BorderColor",
                                value = "%Palette.PrimaryColor4%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "BorderThickness",
                                value = "%Palette.InputBorderThickness%"
                            },
                             new Propertyvaluesmap()
                            {
                                property = "Fill",
                                value = "%Palette.PrimaryColor4%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "Color",
                                value = "%Palette.TextColor1%"
                            },
                        }
                    },
                    new Style()
                    {
                        name = "defaultButtonStyle",
                        controlTemplateName = "Button",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "HoverFill",
                                value = "%Palette.PrimaryColor6%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "HoverColor",
                                value = "%Palette.ReservedWhiteColor%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "PressedFill",
                                value = "%Palette.PrimaryColor6%"
                            },

                            new Propertyvaluesmap()
                            {
                                property = "BorderThickness",
                                value = "%Palette.InputBorderThickness%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "Fill",
                                value = "%Palette.PrimaryColor1%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "Font",
                                value = "%Palette.TextBodyFontFace%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "RadiusTopLeft",
                                value = "%Palette.defaultRadius%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "RadiusTopRight",
                                value = "%Palette.defaultRadius%"
                            },
                             new Propertyvaluesmap()
                            {
                                property = "RadiusBottomLeft",
                                value = "%Palette.defaultRadius%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "RadiusBottomRight",
                                value = "%Palette.defaultRadius%"
                            }
                        }
                    },
                    new Style()
                    {
                        name = "defaultTextStyle",
                        controlTemplateName = "text",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "Font",
                                value = "%Palette.TextBodyFontFace%"
                            },
                             new Propertyvaluesmap()
                            {
                                property = "BorderColor",
                                value = "%Palette.PrimaryColor4%"
                            },
                              new Propertyvaluesmap()
                            {
                                property = "Color",
                                value = "%Palette.TextColor1%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "BorderThickness",
                                value = "%Palette.InputBorderThickness%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "Fill",
                                value = "%Palette.ReservedWhiteColor%"
                            }
                        }
                    },
                    new Style() {
                        name = "defaultCheckboxStyle",
                        controlTemplateName = "checkbox",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "Font",
                                value = "%Palette.TextBodyFontFace%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "CheckboxBorderColor",
                                value = "%Palette.PrimaryColor7%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "CheckboxBackgroundFill",
                                value = "%Palette.ScreenBkgColor%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "CheckmarkFill",
                                value = "%Palette.PrimaryColor1%"
                            }
                        }
                    },
                    new Style() {
                        name = "defaultSliderStyle",
                        controlTemplateName = "slider",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                          new Propertyvaluesmap()
                            {
                                property = "BorderThickness",
                                value = "%Palette.InputBorderThickness%"
                            }
                        }
                    },
                     new Style() {
                        name = "defaultRadioStyle",
                        controlTemplateName = "checkbox",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "Font",
                                value = "%Palette.TextBodyFontFace%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "RadioSelectionFill",
                                value = "%Palette.TextColor2%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "RadioBackgroundFill",
                                value = "%Palette.ReservedWhiteColor%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "RadioBorderColor",
                                value = "%Palette.PrimaryColor1%"
                            },
                               new Propertyvaluesmap()
                            {
                                property = "BorderThickness",
                                value = "%Palette.InputBorderThickness%"
                            }
                        }
                    },
                    new Style()
                    {
                        name = "defaultDropdownStyle",
                        controlTemplateName = "Button",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "SelectionColor",
                                value = "%Palette.ReservedWhiteColor%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "ChevronFill",
                                value = "%Palette.PrimaryColor7%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "ChevronHoverFill",
                                value = "%Palette.PrimaryColor7%"
                            },

                            new Propertyvaluesmap()
                            {
                                property = "ChevronBackground",
                                value = "%Palette.ScreenBkgColor%"
                            },
                             new Propertyvaluesmap()
                            {
                                property = "BorderThickness",
                                value = "%Palette.InputBorderThickness%"
                            }
                         }
                   },
                    new Style()
                    {
                        name = "defaultListboxStyle",
                        controlTemplateName = "Button",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "SelectionColor",
                                value = "%Palette.ReservedWhiteColor%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "SelectionFill",
                                value = "%Palette.PrimaryColor1%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "Color",
                                value = "%Palette.TextColor1%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "HoverColor",
                                value = "%Palette.TextColor1%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "PressedColor",
                                value = "%Palette.ReservedWhiteColor%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "Fill",
                                value = "%Palette.ScreenBkgColor%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "HoverFill",
                                value = "%Palette.PrimaryColor8%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "PressedFill",
                                value = "%Palette.PrimaryColor9%"
                            },
                            new Propertyvaluesmap()
                            {
                                property = "BorderThickness",
                                value = "%Palette.InputBorderThickness%"
                            }
                         }
                   },
                      new Style() {
                        name = "defaultIconStyle",
                        controlTemplateName = "icon",
                        propertyValuesMap = new List<Propertyvaluesmap>()
                        {
                            new Propertyvaluesmap()
                            {
                                property = "Color",
                                value = "%Palette.PrimaryColor9%"
                            }
                        }
                      }
                }
            };
            callback(item, null);
        }
    }
}