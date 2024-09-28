/* ISLANDS VIA VERTS */
clearListener(); print("Cleared in:\n"+getSourceFileName())


ViewportSettings = NitrousGraphicsManager.GetViewportSetting( 1 )
SelectionEffectImpl = NitrousGraphicsManager.GetSelectionSetting()

--ViewportSettings.VisualStyleMode


ViewportSettings.ShowEdgedFacesEnabled = not ViewportSettings.ShowEdgedFacesEnabled


--
--SelectionEffectImpl.SelectionHighlightEnabled = false
--SelectionEffectImpl.PreviewHighlightEnabled = false
--

SelectionEffectImpl.SelectionOutlineEnabled  = not ViewportSettings.ShowEdgedFacesEnabled
SelectionEffectImpl.PreviewOutlineEnabled  = not ViewportSettings.ShowEdgedFacesEnabled