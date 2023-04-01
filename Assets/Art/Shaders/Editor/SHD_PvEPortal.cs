//-----------------------------------------------------------------------
// SHD_PvEPortal.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_PvEPortal : BaseShaderEditor
{
    protected MaterialEditor MaterialEditor;

    MaterialProperty _Mask;
    MaterialProperty _Strength, _Scale, _Speed;
    MaterialProperty _OuterColor, _InnerColor, _Blend, _Intensity;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.MaterialEditor = materialEditor;

        Material targetMat = materialEditor.target as Material;

        _Mask = ShaderGUI.FindProperty("_MainTex", properties);
        _Strength = ShaderGUI.FindProperty("_Strength", properties);
        _Scale = ShaderGUI.FindProperty("_Scale", properties);
        _Speed = ShaderGUI.FindProperty("_Speed", properties);
        _OuterColor = ShaderGUI.FindProperty("_OuterColor", properties);
        _InnerColor = ShaderGUI.FindProperty("_InnerColor", properties);
        _Blend = ShaderGUI.FindProperty("_Blend", properties);
        _Intensity = ShaderGUI.FindProperty("_Intensity", properties);

        Section("Mask", SectionMask);
        Section("Behaviour", SectionBehaviour);
        Section("Visuals", SectionVisuals);
    }

    private void SectionMask()
    {
        MaterialEditor.TexturePropertySingleLine(new GUIContent(" Mask"), _Mask);
    }

    private void SectionBehaviour()
    {
        MaterialEditor.ShaderProperty(_Strength, new GUIContent("Strength"));
        MaterialEditor.ShaderProperty(_Scale, new GUIContent("Scale"));
        MaterialEditor.ShaderProperty(_Speed, new GUIContent("Speed"));
    }

    private void SectionVisuals()
    {
        MaterialEditor.ShaderProperty(_OuterColor, new GUIContent("Outer Color"));
        MaterialEditor.ShaderProperty(_InnerColor, new GUIContent("Inner Color"));
        MaterialEditor.ShaderProperty(_Blend, new GUIContent("Blend"));
        MaterialEditor.ShaderProperty(_Intensity, new GUIContent("Intensity"));
    }
}
