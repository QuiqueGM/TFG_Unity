//-----------------------------------------------------------------------
// SHD_GridHealingEffect.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_GridHealingEffect : SHD_GridEditor
{
    MaterialProperty _rimColor, _rimNoise, _rim;
    MaterialProperty _noiseScale, _noiseStep;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        _rimColor = ShaderGUI.FindProperty("_RimColor", properties);
        _rimNoise = ShaderGUI.FindProperty("_RimNoise", properties);
        _rim = ShaderGUI.FindProperty("_Rim", properties);
        _noiseScale = ShaderGUI.FindProperty("_NoiseScale", properties);
        _noiseStep = ShaderGUI.FindProperty("_NoiseStep", properties);

        Section("Rim/Noise Properties", SectionRimNoise);
    }

    private void SectionRimNoise()
    {
        MaterialEditor.TexturePropertySingleLine(new GUIContent("Rim Noise Map"), _rimNoise, _rimColor);
        MaterialEditor.ShaderProperty(_rim, new GUIContent("Rim Power"));
        MaterialEditor.ShaderProperty(_noiseScale, new GUIContent("Noise Scale"));
        MaterialEditor.ShaderProperty(_noiseStep, new GUIContent("Noise Steps"));
    }
}
