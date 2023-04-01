using UnityEditor;
using UnityEngine;

public class BaseShaderEditor : ShaderGUI
{
    public delegate void DrawSection();

    public virtual void Section(string title, DrawSection onDrawSection, bool addSeparator = true, float labelWidth = 200)
    {
        EditorGUIUtility.labelWidth = labelWidth;
        Header(title);
        onDrawSection();
        Footer(addSeparator);
    }

    public virtual void Header(string title)
    {
        Decorators.HeaderBig(title);
        EditorGUILayout.Space(2);
        EditorGUI.indentLevel++;
    }

    public virtual void Footer(bool addSeparator)
    {
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(3);
        if(addSeparator)
        {
            Decorators.Separator();
        }
    }

    protected Vector2 DrawVector2(MaterialProperty vector2, string label1)
    {
        Vector2 v2 = EditorGUILayout.Vector2Field(label1, new Vector2(vector2.vectorValue.x, vector2.vectorValue.y));
        return new Vector2(v2.x, v2.y);
    }

    protected Vector4 DrawVector4(MaterialProperty vector4, string label1, string label2)
    {
        Vector2 tiling = EditorGUILayout.Vector2Field(label1, new Vector2(vector4.vectorValue.x, vector4.vectorValue.y));
        Vector2 offset = EditorGUILayout.Vector2Field(label2, new Vector2(vector4.vectorValue.z, vector4.vectorValue.w));
        return new Vector4(tiling.x, tiling.y, offset.x, offset.y);
    }

    protected Vector3 DrawVector3(MaterialProperty vector3, string label)
    {
        EditorGUILayout.BeginHorizontal();
        EditorGUIUtility.labelWidth = 100;
        var style = new GUIStyle(GUI.skin.label) { alignment = TextAnchor.UpperRight };

        EditorGUILayout.LabelField(label, style, GUILayout.ExpandWidth(true));
        float x = EditorGUILayout.FloatField(GUIContent.none, vector3.vectorValue.x, GUILayout.MinWidth(70));
        float y = EditorGUILayout.FloatField(GUIContent.none, vector3.vectorValue.y, GUILayout.MinWidth(70));
        float z = EditorGUILayout.FloatField(GUIContent.none, vector3.vectorValue.z, GUILayout.MinWidth(70));
        EditorGUILayout.EndHorizontal();

        return new Vector3(x, y, z);
    }
}


