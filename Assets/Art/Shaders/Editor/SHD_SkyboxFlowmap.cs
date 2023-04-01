//-----------------------------------------------------------------------
// SHD_SkyboxFlowmap.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_SkyboxFlowmap : BaseShaderEditor
{
    protected MaterialEditor MaterialEditor;

    MaterialProperty _tintColor;
    MaterialProperty _mainTex, _flowMap;
    MaterialProperty _rotation, _winDir;
    MaterialProperty _flowStrenght, _windSpeed;
    MaterialProperty _useFog, _fogIntensity;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.MaterialEditor = materialEditor;

        Material targetMat = materialEditor.target as Material;

        _tintColor = ShaderGUI.FindProperty("_TintColor", properties);
        _mainTex = ShaderGUI.FindProperty("_MainTex", properties);
        _flowMap = ShaderGUI.FindProperty("_FlowMap", properties);
        _rotation = ShaderGUI.FindProperty("_Rotation", properties);
        _winDir = ShaderGUI.FindProperty("_WindDir", properties);
        _flowStrenght = ShaderGUI.FindProperty("_FlowStrength", properties);
        _windSpeed = ShaderGUI.FindProperty("_WindSpeed", properties);
        _useFog = ShaderGUI.FindProperty("_UseFog", properties);
        _fogIntensity = ShaderGUI.FindProperty("_FogIntensity", properties);

        Section("Skybox maps", SectionMaps, true, 300);
        Section("Skybox properties", SectionProperties, true, 200);
        Section("Fog", SectionFog, false);
    }

    private void SectionMaps()
    {
        MaterialEditor.TexturePropertySingleLine(new GUIContent("   Spherical (RGB)   Movement Mask (A)"), _mainTex, _tintColor);
        MaterialEditor.TexturePropertySingleLine(new GUIContent("   Flow map"), _flowMap);
    }

    private void SectionProperties()
    {
        MaterialEditor.ShaderProperty(_rotation, new GUIContent("Rotation"));
        MaterialEditor.ShaderProperty(_winDir, new GUIContent("Wind direction"));
        MaterialEditor.ShaderProperty(_windSpeed, new GUIContent("Wind Speed"));
        MaterialEditor.ShaderProperty(_flowStrenght, new GUIContent("Flow strengthness"));
    }

    private void SectionFog()
    {
        MaterialEditor.ShaderProperty(_useFog, new GUIContent("Use Fog"));
        EditorGUILayout.Space(2);

        if(_useFog.floatValue > 0)
        {
            MaterialEditor.ShaderProperty(_fogIntensity, new GUIContent("Fog intensity"));
        }
    }
}
