//-----------------------------------------------------------------------
// SHD_General_SimpleLit.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_General_SimpleLit : BaseShaderEditor
{
    protected MaterialEditor MaterialEditor;
    MaterialProperty _BaseColor, _BaseMap, _TilingOffset;
    MaterialProperty _Smoothness, _Metalness;
    MaterialProperty _EmissionMap, _EmissionColor;
    MaterialProperty _Cutoff;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.MaterialEditor = materialEditor;

        Material targetMat = materialEditor.target as Material;

        _BaseColor = ShaderGUI.FindProperty("_BaseColor", properties);
        _BaseMap = ShaderGUI.FindProperty("_BaseMap", properties);
        _TilingOffset = ShaderGUI.FindProperty("_TilingOffset", properties);
        _Cutoff = ShaderGUI.FindProperty("_Cutoff", properties);
        _Smoothness = ShaderGUI.FindProperty("_Smoothness", properties);
        _Metalness = ShaderGUI.FindProperty("_Metalness", properties);
        _EmissionColor = ShaderGUI.FindProperty("_EmissionColor", properties);
        _EmissionMap = ShaderGUI.FindProperty("_EmissionMap", properties);

        Section("Main Properties", SectionMainProperties);
    }

    private void SectionMainProperties()
    {
        EditorGUI.BeginChangeCheck();
        {
            MaterialEditor.TexturePropertySingleLine(new GUIContent(" Diffuse (RGB)"), _BaseMap, _BaseColor);
            MaterialEditor.TexturePropertySingleLine(new GUIContent(" Emission (RGB)"), _EmissionMap, _EmissionColor);
            _TilingOffset.vectorValue = DrawVector4(_TilingOffset, "Tiling", "Offset");
            MaterialEditor.ShaderProperty(_Cutoff, new GUIContent("Alpha Clip Threshold"));
            MaterialEditor.ShaderProperty(_Smoothness, new GUIContent("Smoothness"));
            MaterialEditor.ShaderProperty(_Metalness, new GUIContent("Metalness"));
        }
    }
}
