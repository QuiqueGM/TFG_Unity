//-----------------------------------------------------------------------
// SHD_GenericMatCapAnimEditor.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_GenericMatCapAnimEditor : BaseShaderEditor
{
    protected MaterialEditor MaterialEditor;
    MaterialProperty _baseColor, _baseMap, _baseMapTillingOffset;
    MaterialProperty _useMatCap, _matCap, _matCapColor, _matCapBlend;
    MaterialProperty _specColor, _specPower, _specSmooth;
    MaterialProperty _directInfluence, _directAttenuation, _ambientLight, _backLight;
    MaterialProperty _useFresnel, _fresnelColor, _fresnelPower, _fresnelIntensity;
    MaterialProperty _saturation, _contrast, _overbright;
    MaterialProperty _useVertexAnim, _overallAnimation, _windScale, _windSpeed;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.MaterialEditor = materialEditor;

        Material targetMat = materialEditor.target as Material;
        try
        {
            _baseColor = ShaderGUI.FindProperty("_BaseColor", properties);
        }
        catch
        {
            _baseColor = ShaderGUI.FindProperty("_Color", properties);
        }

        _baseMap = ShaderGUI.FindProperty("_BaseMap", properties);
        _baseMapTillingOffset = ShaderGUI.FindProperty("_BaseMapTillingOffset", properties);
        _specColor = ShaderGUI.FindProperty("_SpecColor", properties);
        _useMatCap = ShaderGUI.FindProperty("_UseMatCap", properties);
        _matCap = ShaderGUI.FindProperty("_MatCap", properties);
        _matCapColor = ShaderGUI.FindProperty("_MatCapColor", properties);
        _matCapBlend = ShaderGUI.FindProperty("_MatCapBlend", properties);
        _specPower = ShaderGUI.FindProperty("_SpecPower", properties);
        _specSmooth = ShaderGUI.FindProperty("_SpecSmooth", properties);
        _directInfluence = ShaderGUI.FindProperty("_DirectInfluence", properties);
        _directAttenuation = ShaderGUI.FindProperty("_DirectAttenuation", properties);
        _ambientLight = ShaderGUI.FindProperty("_AmbientLight", properties);
        _backLight = ShaderGUI.FindProperty("_BackLight", properties);
        _saturation = ShaderGUI.FindProperty("_Saturation", properties);
        _contrast = ShaderGUI.FindProperty("_Contrast", properties);
        _overbright = ShaderGUI.FindProperty("_Overbright", properties);
        _useFresnel = ShaderGUI.FindProperty("_UseFresnel", properties);
        _fresnelColor = ShaderGUI.FindProperty("_FresnelColor", properties);
        _fresnelPower = ShaderGUI.FindProperty("_FresnelPower", properties);
        _fresnelIntensity = ShaderGUI.FindProperty("_FresnelIntensity", properties);
        _useVertexAnim = ShaderGUI.FindProperty("_UseVertexAnim", properties);
        _overallAnimation = ShaderGUI.FindProperty("_OverallAnimation", properties);
        _windScale = ShaderGUI.FindProperty("_WindScale", properties);
        _windSpeed = ShaderGUI.FindProperty("_WindSpeed", properties);

        Section("Main Properties", SectionMainProperties);
        Section("Material Capture Reflection", SectionMatCap);
        Section("Specular", SectionSpecularity);
        Section("Lighting settings", SectionLighting);
        Section("Fresnel", SectionFresnel);
        Section("Vertex Animation", SectionVertexAnimation);
        Section("Other properties", SectionOtherProperties, false);
    }

    private void SectionMainProperties()
    {
        MaterialEditor.TexturePropertySingleLine(new GUIContent(" Diffuse (RGB)"), _baseMap, _baseColor);
        _baseMapTillingOffset.vectorValue = DrawVector4(_baseMapTillingOffset, "Tilling", "Offset");
    }

    private void SectionMatCap()
    {
        MaterialEditor.ShaderProperty(_useMatCap, new GUIContent("Use Matcap texture"));
        EditorGUILayout.Space(2);

        if(_useMatCap.floatValue > 0)
        {
            MaterialEditor.TexturePropertySingleLine(new GUIContent(" Material Capture"), _matCap, _matCapColor);
            MaterialEditor.ShaderProperty(_matCapBlend, new GUIContent("Reflection Blend"));
        }
    }


    private void SectionSpecularity()
    {
        MaterialEditor.ShaderProperty(_specColor, new GUIContent("Color"));
        MaterialEditor.ShaderProperty(_specPower, new GUIContent("Power"));
        MaterialEditor.ShaderProperty(_specSmooth, new GUIContent("Smoothness"));
    }

    private void SectionLighting()
    {
        MaterialEditor.ShaderProperty(_directInfluence, "Direct Influence");
        MaterialEditor.ShaderProperty(_directAttenuation, "Direct Attenuation");
        MaterialEditor.ShaderProperty(_ambientLight, _ambientLight.displayName);
        MaterialEditor.ShaderProperty(_backLight, _backLight.displayName);
    }

    private void SectionFresnel()
    {
        MaterialEditor.ShaderProperty(_useFresnel, new GUIContent("Use Fresnel"));
        EditorGUILayout.Space(2);

        if(_useFresnel.floatValue > 0)
        {
            MaterialEditor.ShaderProperty(_fresnelColor, new GUIContent("Color"));
            MaterialEditor.ShaderProperty(_fresnelPower, new GUIContent("Power"));
            MaterialEditor.ShaderProperty(_fresnelIntensity, new GUIContent("Intensity"));
        }
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
        MaterialEditor.ShaderProperty(_saturation, _saturation.displayName);
        MaterialEditor.ShaderProperty(_contrast, _contrast.displayName);
        MaterialEditor.ShaderProperty(_overbright, _overbright.displayName);
        MaterialEditor.EnableInstancingField();
    }


}
