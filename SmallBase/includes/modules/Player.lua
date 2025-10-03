--------------------------------------
-- Class: Player
--------------------------------------
-- **Global.**
--
-- **Parent:** `Ped`.
--
-- Class representing a GTA V player (Unfinished).
---@class Player : Ped
---@field private layout CPed
---@overload fun(handle: integer): Player
Player = Class("Player", Ped)
Player.Create = nil
Player.Delete = nil
Player.SetAsNoLongerNeeded = nil

-- Returns whether the player is currently playing by checking their game state.
---@return boolean
function Player:IsPlaying()
    if not self:IsValid() then
        return false
    end

    self:ReadMemoryLayout()
    if not self.layout then
        return false
    end

    local CPlayerInfo = self.layout.CPlayerInfo
    if not CPlayerInfo then
        return false
    end

    local state = CPlayerInfo:GetGameState()
    return (state ~= eGameState.Invalid and state ~= eGameState.LeftGame)
end

-- [WIP]
