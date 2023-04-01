//-----------------------------------------------------------------------
// SHD_FoamIslands.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_FoamIslands : BaseShaderEditor
{
    protected MaterialEditor MaterialEditor;
    MaterialProperty _MainColor;
    MaterialProperty _FoamColor, _FoamMap, _Tilling, _FoamPower, _FoamSpeed;
    MaterialProperty _useVertexAnim, _overallAnimation, _windScale, _windSpeed;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.MaterialEditor = materialEditor;

        Material targetMat = materialEditor.target as Material;
        _MainColor = ShaderGUI.FindProperty("_MainColor", properties);
        _FoamColor = ShaderGUI.FindProperty("_FoamColor", properties);
        _FoamMap = ShaderGUI.FindProperty("_FoamMap", properties);
        _Tilling = ShaderGUI.FindProperty("_Tilling", properties);
        _FoamPower = ShaderGUI.FindProperty("_FoamPower", properties);
        _FoamSpeed = ShaderGUI.FindProperty("_FoamSpeed", properties);

        _useVertexAnim = ShaderGUI.FindProperty("_UseVertexAnim", properties);
        _overallAnimation = ShaderGUI.FindProperty("_OverallAnimation", properties);
        _windScale = ShaderGUI.FindProperty("_WindScale", properties);
        _windSpeed = ShaderGUI.FindProperty("_WindSpeed", properties);

        Section("Main Properties", SectionMainProperties);
        Section("Foam Properties", SectionFoamProperties);
        Section("Vertex Animation", SectionVertexAnimation);
        Section("Other properties", SectionOtherProperties, false);
    }

    private void SectionMainProperties()
    {
        MaterialEditor.ShaderProperty(_MainColor, new GUIContent("Color"));
    }

    private void SectionFoamProperties()
    {
        //MaterialEditor.ShaderProperty(_FoamColor, new GUIContent("Foam Color"));
        MaterialEditor.TexturePropertySingleLine(new GUIContent("Foam Map (R)"), _FoamMap, _FoamColor);
        _Tilling.vectorValue = DrawVector2(_Tilling, "Tilling");
        MaterialEditor.ShaderProperty(_FoamPower, new GUIContent("Power"));
        MaterialEditor.ShaderProperty(_FoamSpeed, new GUIContent("Speed"));
    }

    private void SectionVertexAnimation()
    {
        MaterialEditor.ShaderProperty(_useVertexAnim, new GUIContent("Use Vertex Animation"));
        EditorGUILayout.Space(2);

        if(_useVertexAnim.floatValue > 0)
        {
            MaterialEditor.ShaderProperty(_overallAnimation, new GUIContent("Overall Animation"));
            MaterialEditor.ShaderProperty(_windScale, new GUIContent("Wind Scale"));
            MaterialEditor.ShaderProperty(_windSpeed, new GUIContent("Wind Speed"));
        }
    }

    private void SectionOtherProperties()
    {
        MaterialEditor.EnableInstancingField();
    }


}
