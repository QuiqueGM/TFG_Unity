//-----------------------------------------------------------------------
// DC2SavedBool.cs
//
// Copyright 2021 Social Point SL. All rights reserved.
//
//-----------------------------------------------------------------------
namespace UnityEditor
{
  internal class DC2SavedBool
  {
    private bool m_Value;
    private string m_Name;
    private bool m_Loaded;

    public DC2SavedBool(string name, bool value)
    {
      this.m_Name = name;
      this.m_Loaded = false;
      this.m_Value = value;
    }

    private void Load()
    {
      if (this.m_Loaded)
        return;
      this.m_Loaded = true;
      this.m_Value = EditorPrefs.GetBool(this.m_Name, this.m_Value);
    }

    public bool value
    {
      get
      {
        this.Load();
        return this.m_Value;
      }
      set
      {
        this.Load();
        if (this.m_Value == value)
          return;
        this.m_Value = value;
        EditorPrefs.SetBool(this.m_Name, value);
      }
    }

    public static implicit operator bool(DC2SavedBool s) => s.value;
  }
}
