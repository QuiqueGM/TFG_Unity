//-----------------------------------------------------------------------
// SHD_TerrainSimpleEditor.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_TerrainSimpleEditor : BaseShaderEditor
{
    protected MaterialEditor MaterialEditor;
    MaterialProperty _Color;
    MaterialProperty _Mask, _TllingOffsetMaks;
    MaterialProperty _MainTextureA, _TllingOffsetA;
    MaterialProperty _MainTextureB, _TllingOffsetB;
    MaterialProperty _MainTextureC, _TllingOffsetC;
    MaterialProperty _MainTextureD, _TllingOffsetD;
    MaterialProperty _RimColor, _RimPower;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.MaterialEditor = materialEditor;

        Material targetMat = materialEditor.target as Material;
        _Color = ShaderGUI.FindProperty("_Color", properties);
        _Mask = ShaderGUI.FindProperty("_Mask", properties);
        _TllingOffsetMaks = ShaderGUI.FindProperty("_TllingOffsetMaks", properties);
        _MainTextureA = ShaderGUI.FindProperty("_MainTextureA", properties);
        _TllingOffsetA = ShaderGUI.FindProperty("_TllingOffsetA", properties);
        _MainTextureB = ShaderGUI.FindProperty("_MainTextureB", properties);
        _TllingOffsetB = ShaderGUI.FindProperty("_TllingOffsetB", properties);
        _MainTextureC = ShaderGUI.FindProperty("_MainTextureC", properties);
        _TllingOffsetC = ShaderGUI.FindProperty("_TllingOffsetC", properties);
        _MainTextureD = ShaderGUI.FindProperty("_MainTextureD", properties);
        _TllingOffsetD = ShaderGUI.FindProperty("_TllingOffsetD", properties);

        _RimColor = ShaderGUI.FindProperty("_RimColor", properties);
        _RimPower = ShaderGUI.FindProperty("_RimPower", properties);

        EditorGUI.BeginChangeCheck();
        {
            Section("Main Properties", SectionMainProperties);
            Section("Fresnel", SectionFresnel);
        }
    }

    private void SectionMainProperties()
    {
        MaterialEditor.ShaderProperty(_Color, new GUIContent("Tint Color"));
        EditorGUILayout.Space(5);
        MaterialEditor.TexturePropertySingleLine(new GUIContent("_Mask"), _Mask);
        _TllingOffsetMaks.vectorValue = DrawVector4(_TllingOffsetMaks, "Tilling", "Offset");
        EditorGUILayout.Space(3);
        MaterialEditor.TexturePropertySingleLine(new GUIContent("_Mask"), _MainTextureA);
        _TllingOffsetA.vectorValue = DrawVector4(_TllingOffsetA, "Tilling", "Offset");
        EditorGUILayout.Space(3);
        MaterialEditor.TexturePropertySingleLine(new GUIContent("_Mask"), _MainTextureB);
        _TllingOffsetB.vectorValue = DrawVector4(_TllingOffsetB, "Tilling", "Offset");
        EditorGUILayout.Space(3);
        MaterialEditor.TexturePropertySingleLine(new GUIContent("_Mask"), _MainTextureC);
        _TllingOffsetC.vectorValue = DrawVector4(_TllingOffsetC, "Tilling", "Offset");
        EditorGUILayout.Space(3);
        MaterialEditor.TexturePropertySingleLine(new GUIContent("_Mask"), _MainTextureD);
        _TllingOffsetD.vectorValue = DrawVector4(_TllingOffsetD, "Tilling", "Offset");
        EditorGUILayout.Space(3);
    }

    private void SectionFresnel()
    {
        MaterialEditor.ShaderProperty(_RimColor, new GUIContent("Rim Color"));
        MaterialEditor.ShaderProperty(_RimPower, new GUIContent("Rim Power"));
    }
}
