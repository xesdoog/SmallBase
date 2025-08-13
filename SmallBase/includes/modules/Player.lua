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
        error("Failed to read CPed", 0)
    end

    local CPlayerInfo = self.layout.CPlayerInfo
    if not CPlayerInfo then
        error("Failed to read CPlayerInfo", 0)
    end

    local iState = CPlayerInfo.GetGameState()
    return (iState ~= eGameState.Invalid and iState ~= eGameState.LeftGame)
end

-- [WIP]
