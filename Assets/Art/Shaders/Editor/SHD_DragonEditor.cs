//-----------------------------------------------------------------------
// SHD_DragonEditor.cs
//
// Copyright 2020 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_DragonEditor : SHD_EggEditor
{
    MaterialProperty _dissolveNoiseTexture, _dissolveEffectAmount, _dissolveColor, _dissolveEdge, _dissolveScale;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        _dissolveNoiseTexture = ShaderGUI.FindProperty("_DissolveNoiseTexture", properties);
        _dissolveScale = ShaderGUI.FindProperty("_DissolveScale", properties);
        _dissolveEffectAmount = ShaderGUI.FindProperty("_DissolveEffectAmount", properties);
        _dissolveColor = ShaderGUI.FindProperty("_DissolveColor", properties);
        _dissolveEdge = ShaderGUI.FindProperty("_DissolveEdge", properties);

        Decorators.Separator();
        Section("Dissolve Effect", SectionDissolve, false);
    }

    private void SectionDissolve()
    {
        MaterialEditor.TexturePropertySingleLine(new GUIContent("Noise Map"), _dissolveNoiseTexture, _dissolveScale);
        MaterialEditor.ShaderProperty(_dissolveColor, new GUIContent("Edge Color"));
        MaterialEditor.ShaderProperty(_dissolveEdge, new GUIContent("Edge Thickness"));
    }


}
