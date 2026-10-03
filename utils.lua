local addonName, privateTable = ...

privateTable.Utils = {}

--- Validates if a UI object exposes the required API surface and is not protected by the client's security model.
--- @param frame table|userdata The UI object to evaluate.
--- @return boolean True if the object is safe to manipulate.
function privateTable.Utils.IsFrameAccessible(frame)
    if type(frame) ~= "table" and type(frame) ~= "userdata" then
        return false
    end

    if type(frame.GetAlpha) ~= "function" or type(frame.SetAlpha) ~= "function" then
        return false
    end

    if type(frame.IsForbidden) == "function" and frame:IsForbidden() then
        return false
    end

    return true
end