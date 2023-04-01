//-----------------------------------------------------------------------
// SHD_EggEditor.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using UnityEditor;
using UnityEngine;

public class SHD_DragonEditor : BaseShaderEditor
{
    protected MaterialEditor MaterialEditor;
    MaterialProperty _mainTex, _normalMap;
    MaterialProperty _useEmission, _useMetallic;
    MaterialProperty _emissiveMetallicMap, _emissionColor;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        this.MaterialEditor = materialEditor;

        _mainTex = ShaderGUI.FindProperty("_MainTex", properties);
        _normalMap = ShaderGUI.FindProperty("_NormalMap", properties);
        _useEmission = ShaderGUI.FindProperty("_UseEmission", properties);
        _useMetallic = ShaderGUI.FindProperty("_UseMetallic", properties);
        _emissiveMetallicMap = ShaderGUI.FindProperty("_EmissiveMetallicMap", properties);
        _emissionColor = ShaderGUI.FindProperty("_EmissionColor", properties);

        Section("Main maps", SectionMainMaps);
        Section("Extra maps", SectionExtraMaps, true, 300);
    }

    private void SectionMainMaps()
    {
        MaterialEditor.TexturePropertySingleLine((new GUIContent(_mainTex.displayName)), _mainTex);
        MaterialEditor.TexturePropertySingleLine(new GUIContent("Normal Map"), _normalMap);
    }

    private void SectionExtraMaps()
    {
        MaterialEditor.ShaderProperty(_useEmission, _useEmission.displayName);
        MaterialEditor.ShaderProperty(_useMetallic, _useMetallic.displayName);

        if(_useEmission.floatValue >= 1 && _useMetallic.floatValue >= 1)
        {
            MaterialEditor.TexturePropertySingleLine((new GUIContent("Emissive (RGB)  Metallic (A)")), _emissiveMetallicMap, _emissionColor);
        }
        else if(_useEmission.floatValue >= 1 && _useMetallic.floatValue < 1)
        {
            MaterialEditor.TexturePropertySingleLine((new GUIContent("Emissive (RGB)")), _emissiveMetallicMap, _emissionColor);
        }
        else if(_useEmission.floatValue < 1 && _useMetallic.floatValue >= 1)
        {
            MaterialEditor.TexturePropertySingleLine((new GUIContent("Metallic (R)")), _emissiveMetallicMap);
        }
    }
}
