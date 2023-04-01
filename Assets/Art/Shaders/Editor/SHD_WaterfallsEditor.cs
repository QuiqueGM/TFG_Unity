//-----------------------------------------------------------------------
// SHD_WaterfallsEditor.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_WaterfallsEditor : BaseShaderEditor
{
    protected MaterialEditor MaterialEditor;
    MaterialProperty _Mask;
    MaterialProperty _UpColor, _MidColor, _DownColor;
    MaterialProperty _Threshold, _Edge;
    MaterialProperty _FoamColor, _FoamDispersion, _FoamBack, _FoamFront;


    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.MaterialEditor = materialEditor;

        Material targetMat = materialEditor.target as Material;

        _Mask = ShaderGUI.FindProperty("_Mask", properties);
        _UpColor = ShaderGUI.FindProperty("_UpColor", properties);
        _MidColor = ShaderGUI.FindProperty("_MidColor", properties);
        _DownColor = ShaderGUI.FindProperty("_DownColor", properties);
        _Threshold = ShaderGUI.FindProperty("_Threshold", properties);
        _Edge = ShaderGUI.FindProperty("_Edge", properties);
        _FoamColor = ShaderGUI.FindProperty("_FoamColor", properties);
        _FoamDispersion = ShaderGUI.FindProperty("_FoamDispersion", properties);
        _FoamBack = ShaderGUI.FindProperty("_FoamBack", properties);
        _FoamFront = ShaderGUI.FindProperty("_FoamFront", properties);

        Section("Mask & Colors", SectionMaskColors);
        Section("Falling", SectionFallingEffect);
        Section("Foam", SectionFoamEffect);
    }

    private void SectionMaskColors()
    {
        MaterialEditor.TexturePropertySingleLine(new GUIContent(" Diffuse (RGB)"), _Mask);
        EditorGUILayout.Space(4);
        MaterialEditor.ShaderProperty(_UpColor, new GUIContent("Up Color"));
        MaterialEditor.ShaderProperty(_MidColor, new GUIContent("Mid Color"));
        MaterialEditor.ShaderProperty(_DownColor, new GUIContent("Down Color"));
    }

    private void SectionFallingEffect()
    {
        MaterialEditor.ShaderProperty(_Threshold, new GUIContent("Threshold"));
        MaterialEditor.ShaderProperty(_Edge, new GUIContent("Edge"));
        _FoamDispersion.vectorValue = DrawVector2(_FoamDispersion, "Mask Speed");
    }

    private void SectionFoamEffect()
    {
        MaterialEditor.ShaderProperty(_FoamColor, new GUIContent("Color"));
        EditorGUILayout.Space(4);
        Decorators.SubHeaderGray("Front Foam");
        _FoamBack.vectorValue = DrawVector4(_FoamBack, "Tiling", "Speed");
        EditorGUILayout.Space(2);
        Decorators.SubHeaderGray("Back Foam");
        _FoamFront.vectorValue = DrawVector4(_FoamFront, "Tiling", "Speed");
    }
}
