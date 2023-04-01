//-----------------------------------------------------------------------
// SHD_GridEditor.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
using SocialPoint.TA.Utils;
using UnityEditor;
using UnityEngine;

public class SHD_GridEditor : SHD_GenericTilingOffsetEditor
{
    MaterialProperty _useGrid, _gridColor, _gridFrequencyOffset;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);

        _useGrid = ShaderGUI.FindProperty("_UseGrid", properties);
        _gridColor = ShaderGUI.FindProperty("_GridColor", properties);
        _gridFrequencyOffset = ShaderGUI.FindProperty("_GridFrequencyOffset", properties);

        Section("Grid Properties", SectionGrid, false);
    }

    private void SectionGrid()
    {
        MaterialEditor.ShaderProperty(_useGrid, new GUIContent("Use Grid"));
        EditorGUILayout.Space(2);

        if(_useGrid.floatValue > 0)
        {
            MaterialEditor.ShaderProperty(_gridColor, new GUIContent("Color"));
            _gridFrequencyOffset.vectorValue = DrawVector4(_gridFrequencyOffset, "Frequency", "Offset");
        }
    }
}
