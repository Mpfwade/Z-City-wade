function hg.Zombify(ply)
    if !IsValid(ply) or !ply.SetPlayerClass then return end
    ply:SetPlayerClass("zombie")
end