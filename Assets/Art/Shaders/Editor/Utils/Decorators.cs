//-----------------------------------------------------------------------
// Decorators.cs
//
// Copyright 2020 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using System.Collections.Generic;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace SocialPoint.TA.Utils
{
    public static class Decorators
    {
        static GUIContent tempGuiContent = new GUIContent();

        public static GUIContent TempContent(string label, Texture2D icon)
        {
            tempGuiContent.text = label;
            tempGuiContent.image = icon;
            tempGuiContent.tooltip = null;
            return tempGuiContent;
        }

        public static GUIContent TempContent(string label, string tooltip = null, Texture2D icon = null)
        {
            tempGuiContent.text = label;
            tempGuiContent.image = icon;
            tempGuiContent.tooltip = tooltip;
            return tempGuiContent;
        }

        public static Texture2D TextureCustomColor(Texture2D source, Color color)
        {
            int hash = source.GetHashCode() + color.GetHashCode();
            if (customColorTextures.ContainsKey(hash))
            {
                if (customColorTextures[hash] != null)
                {
                    return customColorTextures[hash];
                }
                else
                {
                    customColorTextures.Remove(hash);
                }
            }

            var tex2D = new Texture2D(source.width, source.height, source.format, false);
            tex2D.name = source.name + " " + color;
            tex2D.hideFlags = HideFlags.DontUnloadUnusedAsset;
            var pixels = source.GetPixels32();
            var color32 = (Color32)color;

            for (int i = 0; i < pixels.Length; i++)
            {
                color32.a = pixels[i].a;
                pixels[i] = color32;
            }

            tex2D.SetPixels32(pixels);
            tex2D.Apply(false, true);

            customColorTextures.Add(hash, tex2D);

            return tex2D;
        }
        static Dictionary<int, Texture2D> customColorTextures = new Dictionary<int, Texture2D>();

        static GUIStyle ShurikenMiniButtonBorder(GUIStyle source)
        {
            var style = new GUIStyle(source)
            {
                border = new RectOffset(5, 5, 5, 5),
                margin = new RectOffset(0, 0, 0, 0),
            };

            style.onActive.background = style.onNormal.background;
            style.onActive.scaledBackgrounds = style.onNormal.scaledBackgrounds;
            return style;
        }

        private static GUIStyle _ShurikenMiniButton;
        public static GUIStyle ShurikenMiniButton
        {
            get
            {
                if (_ShurikenMiniButton == null) _ShurikenMiniButton = ShurikenMiniButtonBorder(EditorStyles.miniButton);
                return _ShurikenMiniButton;
            }
        }

        private static GUIStyle _ShurikenMiniButtonLeft;
        public static GUIStyle ShurikenMiniButtonLeft
        {
            get
            {
                if (_ShurikenMiniButtonLeft == null) _ShurikenMiniButtonLeft = ShurikenMiniButtonBorder(EditorStyles.miniButtonLeft);
                return _ShurikenMiniButtonLeft;
            }
        }

        private static GUIStyle _ShurikenMiniButtonMid;
        public static GUIStyle ShurikenMiniButtonMid
        {
            get
            {
                if (_ShurikenMiniButtonMid == null) _ShurikenMiniButtonMid = ShurikenMiniButtonBorder(EditorStyles.miniButtonMid);
                return _ShurikenMiniButtonMid;
            }
        }

        private static GUIStyle _ShurikenMiniButtonRight;
        public static GUIStyle ShurikenMiniButtonRight
        {
            get
            {
                if (_ShurikenMiniButtonRight == null) _ShurikenMiniButtonRight = ShurikenMiniButtonBorder(EditorStyles.miniButtonRight);
                return _ShurikenMiniButtonRight;
            }
        }

        private static GUIStyle _HeaderLabel;
        private static GUIStyle HeaderLabel
        {
            get
            {
                if (_HeaderLabel == null)
                {
                    _HeaderLabel = new GUIStyle(EditorStyles.label);
                    _HeaderLabel.fontStyle = FontStyle.Bold;

                    var gray1 = EditorGUIUtility.isProSkin ? 0.7f : 0.35f;
                    _HeaderLabel.normal.textColor = new Color(gray1, gray1, gray1);
                }
                return _HeaderLabel;
            }
        }

        private static GUIStyle _HeaderDropDown;
        public static GUIStyle HeaderDropDown
        {
            get
            {
                if (_HeaderDropDown == null)
                {
                    _HeaderDropDown = new GUIStyle(EditorStyles.foldout);

                    _HeaderDropDown.focused.background = _HeaderDropDown.normal.background;
                    _HeaderDropDown.active.background = _HeaderDropDown.normal.background;
                    _HeaderDropDown.onFocused.background = _HeaderDropDown.onNormal.background;
                    _HeaderDropDown.onActive.background = _HeaderDropDown.onNormal.background;

                    var gray1 = EditorGUIUtility.isProSkin ? 0.8f : 0.0f;
                    var gray2 = EditorGUIUtility.isProSkin ? 0.65f : 0.3f;

                    var textColor = new Color(gray1, gray1, gray1);
                    var textColorActive = new Color(gray2, gray2, gray2);
                    _HeaderDropDown.normal.textColor = textColor;
                    _HeaderDropDown.onNormal.textColor = textColor;
                    _HeaderDropDown.focused.textColor = textColor;
                    _HeaderDropDown.onFocused.textColor = textColor;
                    _HeaderDropDown.active.textColor = textColorActive;
                    _HeaderDropDown.onActive.textColor = textColorActive;
                }
                return _HeaderDropDown;
            }
        }

        private static GUIStyle _HeaderDropDownBold;
        public static GUIStyle HeaderDropDownBold
        {
            get
            {
                if (_HeaderDropDownBold == null)
                {
                    _HeaderDropDownBold = new GUIStyle(HeaderDropDown);
                    _HeaderDropDownBold.fontStyle = FontStyle.Bold;

                    var gray1 = EditorGUIUtility.isProSkin ? 0.6f : 0.3f;
                    var gray2 = EditorGUIUtility.isProSkin ? 0.5f : 0.45f;

                    var textColor = new Color(gray1, gray1, gray1);
                    var textColorActive = new Color(gray2, gray2, gray2);
                    _HeaderDropDownBold.normal.textColor = textColor;
                    _HeaderDropDownBold.onNormal.textColor = textColor;
                    _HeaderDropDownBold.focused.textColor = textColor;
                    _HeaderDropDownBold.onFocused.textColor = textColor;
                    _HeaderDropDownBold.active.textColor = textColorActive;
                    _HeaderDropDownBold.onActive.textColor = textColorActive;
                }
                return _HeaderDropDownBold;
            }
        }

        private static GUIStyle _HeaderDropDownBoldGray;
        public static GUIStyle HeaderDropDownBoldGray
        {
            get
            {
                if (_HeaderDropDownBoldGray == null)
                {
                    _HeaderDropDownBoldGray = new GUIStyle(HeaderDropDownBold);
                    var gray1 = EditorGUIUtility.isProSkin ? 0.5f : 0.35f;
                    var gray2 = EditorGUIUtility.isProSkin ? 0.4f : 0.45f;
                    var textColor = new Color(gray1, gray1, gray1);
                    var textColorActive = new Color(gray2, gray2, gray2);
                    _HeaderDropDownBoldGray.normal.textColor = textColor;
                    _HeaderDropDownBoldGray.onNormal.textColor = textColor;
                    _HeaderDropDownBoldGray.focused.textColor = textColor;
                    _HeaderDropDownBoldGray.onFocused.textColor = textColor;
                    _HeaderDropDownBoldGray.active.textColor = textColorActive;
                    _HeaderDropDownBoldGray.onActive.textColor = textColorActive;
                }
                return _HeaderDropDownBoldGray;
            }
        }

        private static GUIStyle _HeaderDropDownBoldError;
        public static GUIStyle HeaderDropDownBoldError
        {
            get
            {
                if (_HeaderDropDownBoldError == null)
                {
                    _HeaderDropDownBoldError = new GUIStyle(HeaderDropDownBold);
                    var textColor = EditorGUIUtility.isProSkin ? new Color(0.85f, 0.1f, 0) : new Color(0.8f, 0, 0);
                    var textColorActive = EditorGUIUtility.isProSkin ? new Color(0.7f, 0.1f, 0) : new Color(1.0f, 0, 0);

                    _HeaderDropDownBoldError.normal.textColor = textColor;
                    _HeaderDropDownBoldError.onNormal.textColor = textColor;
                    _HeaderDropDownBoldError.focused.textColor = textColor;
                    _HeaderDropDownBoldError.onFocused.textColor = textColor;
                    _HeaderDropDownBoldError.active.textColor = textColorActive;
                    _HeaderDropDownBoldError.onActive.textColor = textColorActive;
                }
                return _HeaderDropDownBoldError;
            }
        }

        private static GUIStyle _SubHeaderLabel;
        public static GUIStyle SubHeaderLabel
        {
            get
            {
                if (_SubHeaderLabel == null)
                {
                    _SubHeaderLabel = new GUIStyle(EditorStyles.label);
                    _SubHeaderLabel.fontStyle = FontStyle.Normal;
                    _SubHeaderLabel.normal.textColor = EditorGUIUtility.isProSkin ? new Color(0.5f, 0.5f, 0.5f) : new Color(0.35f, 0.35f, 0.35f);
                }
                return _SubHeaderLabel;
            }
        }

        private static GUIStyle _BigHeaderLabel;
        public static GUIStyle BigHeaderLabel
        {
            get
            {
                if (_BigHeaderLabel == null)
                {
                    _BigHeaderLabel = new GUIStyle(EditorStyles.largeLabel);
                    _BigHeaderLabel.fontStyle = FontStyle.Bold;
                    _BigHeaderLabel.fixedHeight = 30;
                }
                return _BigHeaderLabel;
            }
        }

        private static GUIStyle _BigFoldoutBold;
        public static GUIStyle BigFoldoutBold
        {
            get
            {
                if (_BigFoldoutBold == null)
                {
                    _BigFoldoutBold = new GUIStyle(EditorStyles.foldout);
                    _BigFoldoutBold.fontStyle = FontStyle.Bold;
                    _TextInfoSize8.fontSize = 12;
                    _BigFoldoutBold.fixedHeight = 40;
                }
                return _BigFoldoutBold;
            }
        }

        private static GUIStyle _FoldoutBold;
        public static GUIStyle FoldoutBold
        {
            get
            {
                if (_FoldoutBold == null)
                {
                    _FoldoutBold = new GUIStyle(EditorStyles.foldout);
                    _FoldoutBold.fontStyle = FontStyle.Bold;
                }
                return _FoldoutBold;
            }
        }

        public static GUIStyle _LineStyle;
        public static GUIStyle LineStyle
        {
            get
            {
                if (_LineStyle == null)
                {
                    _LineStyle = new GUIStyle();
                    _LineStyle.normal.background = EditorGUIUtility.whiteTexture;
                    _LineStyle.stretchWidth = true;
                }

                return _LineStyle;
            }
        }

        static GUIStyle _HelpBoxRichTextStyle;
        public static GUIStyle HelpBoxRichTextStyle
        {
            get
            {
                if (_HelpBoxRichTextStyle == null)
                {
                    _HelpBoxRichTextStyle = new GUIStyle("HelpBox");
                    _HelpBoxRichTextStyle.richText = true;
                    _HelpBoxRichTextStyle.margin = new RectOffset(4, 4, 0, 0);
                    _HelpBoxRichTextStyle.padding = new RectOffset(4, 4, 4, 4);
                }
                return _HelpBoxRichTextStyle;
            }
        }

        static GUIStyle _TextInfoSize8;
        public static GUIStyle TextInfoSize8
        {
            get
            {
                if (_TextInfoSize8 == null)
                {
                    _TextInfoSize8 = new GUIStyle(EditorStyles.miniLabel);
                    _TextInfoSize8.fontSize = 8;
                    _TextInfoSize8.fixedHeight = 12;
                }
                return _TextInfoSize8;
            }
        }

        static GUIStyle _TextInfoSmall;
        public static GUIStyle TextInfoSmall
        {
            get
            {
                if (_TextInfoSmall == null)
                {
                    _TextInfoSmall = new GUIStyle(EditorStyles.miniLabel);
                    _TextInfoSmall.fontSize = 9;
                    _TextInfoSmall.fixedHeight = 12;
                }
                return _TextInfoSmall;
            }
        }

        public static void SeparatorSimple()
        {
            var color = EditorGUIUtility.isProSkin ? new Color(0.15f, 0.15f, 0.15f) : new Color(0.65f, 0.65f, 0.65f);
            GUILine(color, 1);
            GUILayout.Space(1);
        }

        public static void Separator()
        {
            var colorDark = EditorGUIUtility.isProSkin ? new Color(.1f, .1f, .1f) : new Color(.3f, .3f, .3f);
            var colorBright = EditorGUIUtility.isProSkin ? new Color(.3f, .3f, .3f) : new Color(.9f, .9f, .9f);

            GUILayout.Space(4);
            GUILine(colorDark, 1);
            GUILine(colorBright, 1);
            GUILayout.Space(4);
        }

        public static void Separator(Rect position)
        {
            var colorDark = EditorGUIUtility.isProSkin ? new Color(.1f, .1f, .1f) : new Color(.3f, .3f, .3f);
            var colorBright = EditorGUIUtility.isProSkin ? new Color(.3f, .3f, .3f) : new Color(.9f, .9f, .9f);

            var lineRect = position;
            lineRect.height = 1;
            GUILine(lineRect, colorDark, 1);
            lineRect.y += 1;
            GUILine(lineRect, colorBright, 1);
        }

        public static void SeparatorBig()
        {
            GUILayout.Space(10);
            GUILine(new Color(.3f, .3f, .3f), 2);
            GUILayout.Space(1);
            GUILine(new Color(.3f, .3f, .3f), 2);
            GUILine(new Color(.85f, .85f, .85f), 1);
            GUILayout.Space(2);
        }

        public static void GUILine(float height = 2f)
        {
            GUILine(Color.black, height);
        }

        public static void GUILine(Color color, float height = 2f)
        {
            var position = GUILayoutUtility.GetRect(0f, float.MaxValue, height, height, LineStyle);

            if (Event.current.type == EventType.Repaint)
            {
                var orgColor = GUI.color;
                GUI.color = orgColor * color;
                LineStyle.Draw(position, false, false, false, false);
                GUI.color = orgColor;
            }
        }
        public static void GUILine(Rect position, Color color, float height = 2f)
        {
            if (Event.current.type == EventType.Repaint)
            {
                var orgColor = GUI.color;
                GUI.color = orgColor * color;
                LineStyle.Draw(position, false, false, false, false);
                GUI.color = orgColor;
            }
        }

        public static void Header(string header, string tooltip = null, bool expandWidth = false)
        {
            if (tooltip != null)
                EditorGUILayout.LabelField(TempContent(header, tooltip), HeaderLabel, GUILayout.ExpandWidth(expandWidth));
            else
                EditorGUILayout.LabelField(header, HeaderLabel, GUILayout.ExpandWidth(expandWidth));
        }

        public static void Header(Rect position, string header, string tooltip = null, bool expandWidth = false)
        {
            if (tooltip != null)
                EditorGUI.LabelField(position, TempContent(header, tooltip), HeaderLabel);
            else
                EditorGUI.LabelField(position, header, HeaderLabel);
        }

        public static bool HeaderFoldout(bool foldout, GUIContent guiContent)
        {
            foldout = EditorGUILayout.Foldout(foldout, guiContent, true, HeaderDropDownBold);
            return foldout;
        }

        public static void SubHeaderGray(string header, string tooltip = null, bool expandWidth = false)
        {
            if (tooltip != null)
                EditorGUILayout.LabelField(TempContent(header, tooltip), SubHeaderLabel, GUILayout.ExpandWidth(expandWidth));
            else
                EditorGUILayout.LabelField(header, SubHeaderLabel, GUILayout.ExpandWidth(expandWidth));
        }

        public static void HeaderBig(string header, string tooltip = null)
        {
            if (tooltip != null)
                EditorGUILayout.LabelField(TempContent(header, tooltip), BigHeaderLabel);
            else
                EditorGUILayout.LabelField(header, BigHeaderLabel);
        }

        public static bool Button(GUIStyle icon, string noIconText, string tooltip = null)
        {
            if (icon == null)
                return GUILayout.Button(TempContent(noIconText, tooltip), EditorStyles.miniButton);
            return GUILayout.Button(TempContent("", tooltip), icon);
        }

        public static bool Button(Rect rect, GUIStyle icon, string noIconText, string tooltip = null)
        {
            if (icon == null)
                return GUI.Button(rect, TempContent(noIconText, tooltip), EditorStyles.miniButton);
            return GUI.Button(rect, TempContent("", tooltip), icon);
        }

        public static int RadioChoice(int choice, bool horizontal, params string[] labels)
        {
            var guiContents = new GUIContent[labels.Length];
            for (var i = 0; i < guiContents.Length; i++)
            {
                guiContents[i] = TempContent(labels[i]);
            }
            return RadioChoice(choice, horizontal, guiContents);
        }
        public static int RadioChoice(int choice, bool horizontal, params GUIContent[] labels)
        {
            if (horizontal)
                EditorGUILayout.BeginHorizontal();

            for (var i = 0; i < labels.Length; i++)
            {
                var style = EditorStyles.miniButton;
                if (labels.Length > 1)
                {
                    if (i == 0)
                        style = EditorStyles.miniButtonLeft;
                    else if (i == labels.Length-1)
                        style = EditorStyles.miniButtonRight;
                    else
                        style = EditorStyles.miniButtonMid;
                }

                if (GUILayout.Toggle(i == choice, labels[i], style))
                {
                    choice = i;
                }
            }

            if (horizontal)
                EditorGUILayout.EndHorizontal();

            return choice;
        }

        public static int RadioChoiceHorizontal(Rect position, int choice, params GUIContent[] labels)
        {
            for (var i = 0; i < labels.Length; i++)
            {
                var rI = position;
                rI.width /= labels.Length;
                rI.x += i * rI.width;
                if (GUI.Toggle(rI, choice == i, labels[i], (i == 0) ? EditorStyles.miniButtonLeft : (i == labels.Length - 1) ? EditorStyles.miniButtonRight : EditorStyles.miniButtonMid))
                {
                    choice = i;
                }
            }

            return choice;
        }
    }
}
