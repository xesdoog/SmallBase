---@diagnostic disable: param-type-mismatch, lowercase-global

local API_VER <const> = Backend:GetAPIVersion()

---@enum eThreadState
eThreadState = {
    UNK = -1,
    DEAD = 0,
    RUNNING = 1,
    SUSPENDED = 2,
}

--#region Thread

---@class Thread : ClassMeta<Thread>
---@field private m_name string
---@field private m_callback function
---@field private m_can_run boolean
---@field private m_was_started boolean
---@field private m_should_pause boolean
---@field private m_state eThreadState
---@field private m_time_created number
---@field private m_time_started number
---@overload fun(name: string, callback: function): Thread
local Thread = Class("Thread")
function Thread.new(name, callback)
    return setmetatable(
        {
            m_name         = name,
            m_callback     = callback,
            m_can_run      = false,
            m_was_started  = false,
            m_should_pause = false,
            m_state        = eThreadState.UNK,
            m_time_created = Time.now(),
            m_time_started = 0
        },
        Thread
    )
end

---@return string
function Thread:GetName()
    return self.m_name
end

---@return eThreadState
function Thread:GetState()
    return self.m_state
end

---@return function
function Thread:GetCallback()
    return self.m_callback
end

function Thread:GetTimeCreated()
    return self.m_time_created
end

function Thread:GetTimeStarted()
    return self.m_time_started
end

function Thread:GetRunningTime()
    if (type(self.m_time_started) ~= "number" or self.m_time_started < 1) then
        return "00:00:00"
    end

    local ago = math.floor(Time.now() - self.m_time_started)
    local hours = math.floor(ago / 3600)
    local minutes = math.floor((ago % 3600) / 60)
    local seconds = ago % 60

    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

---@return boolean
function Thread:CanRun()
    return self.m_can_run and type(self.m_callback) == "function"
end

---@return boolean
function Thread:IsRunning()
    return self.m_state == eThreadState.RUNNING
end

---@return boolean
function Thread:IsSuspended()
    return self.m_state == eThreadState.SUSPENDED
end

function Thread:Tick()
    self.m_can_run = (type(self.m_callback) == "function")
    self.m_time_started = Time.now()

    while self.m_can_run do
        if self.m_should_pause then
            self.m_state = eThreadState.SUSPENDED
            self.m_time_started = 0
            repeat
                yield()
            until not self.m_should_pause
        end

        self.m_was_started = true
        self.m_state = eThreadState.RUNNING
        self.m_callback()
        yield()
    end
end

function Thread:Start()
    if (self.m_state == eThreadState.DEAD) then
        return false
    end

    self.m_state = eThreadState.RUNNING
    self.m_can_run = true
    self.m_time_started = Time.now()
    return true
end

function Thread:Stop()
    self.m_time_started = 0
    self.m_can_run = false
    self.m_state = eThreadState.DEAD
end

function Thread:Suspend()
    self.m_time_started = 0
    self.m_should_pause = true
end

function Thread:Resume()
    self.m_should_pause = false
    self.m_time_started = Time.now()
end

--#endregion


----------------------------------------------
----------------------------------------------
----------------------------------------------
---@class ThreadManager : ClassMeta<ThreadManager>
---@field private m_threads table<string, Thread>
local ThreadManager = Class("ThreadManager")

---@return ThreadManager
function ThreadManager:init()
    local instance = setmetatable({ m_threads = {} }, self)
    Backend:RegisterEventCallback(eBackendEvent.RELOAD_UNLOAD, function()
        instance:Shutdown()
    end)

    return instance
end

function ThreadManager:RunInFiber(func)
    if (API_VER == eAPIVersion.V1) then
        script.run_in_fiber(func)
    elseif (API_VER == eAPIVersion.V2) then
        ---@diagnostic disable-next-line: undefined-field
        script.run_in_callback(func)
    else
        func({ sleep = function() end, yield = function() end })
    end
end

---@param name string
---@param func function
---@param start_suspended? boolean
function ThreadManager:StartNewThread(name, func, start_suspended)
    if self:IsThreadRegistered(name) then
        log.fwarning("Thread '%s' is already registered!", name)
        return
    end

    local thread = Thread(name, func)
    if start_suspended then
        thread:Suspend()
    end

    self.m_threads[name] = thread
    if (API_VER ~= eAPIVersion.L54) then
        self:RunInFiber(function()
            thread:Tick()
        end)
    else
        Backend:debug("Thread '%s' registered in mock environment but not started.", name)
    end

    return thread
end

---@return Thread
function ThreadManager:GetThread(name)
    return self.m_threads[name]
end

---@return eThreadState
function ThreadManager:GetThreadState(name)
    local thread = self:GetThread(name)
    if not thread then
        return eThreadState.UNK
    end

    return thread:GetState()
end

function ThreadManager:ListThreads()
    return self.m_threads
end

---@param name string
---@return boolean
function ThreadManager:IsThreadRegistered(name)
    return self.m_threads[name] ~= nil
end

---@param name string
---@return boolean
function ThreadManager:IsThreadRunning(name)
    local thread = self:GetThread(name)
    return thread and thread:IsRunning()
end

---@param name string
function ThreadManager:StartThread(name)
    local thread = self:GetThread(name)
    if not thread then
        return
    end

    local ok = thread:Start()
    if not ok then
        local func = thread:GetCallback()
        local new_thread = Thread(name, func)
        self.m_threads[name] = new_thread

        if (API_VER == eAPIVersion.L54) then
            return
        end

        self:RunInFiber(function()
            new_thread:Tick()
        end)
    end
end

---@param name string
function ThreadManager:SuspendThread(name)
    local thread = self:GetThread(name)
    if not thread then
        return
    end

    thread:Suspend()
end

---@param name string
function ThreadManager:ResumeThread(name)
    local thread = self:GetThread(name)
    if not thread then
        return
    end

    thread:Resume()
end

---@param name string
function ThreadManager:StopThread(name)
    local thread = self:GetThread(name)
    if not thread then
        return
    end

    thread:Stop()
end

---@param name string
function ThreadManager:RemoveThread(name)
    self:StopThread(name)
    self.m_threads[name] = nil
end

function ThreadManager:SuspendAllThreads()
    for _, thread in pairs(self.m_threads) do
        thread:Suspend()
    end
end

function ThreadManager:ResumeAllThreads()
    for _, thread in pairs(self.m_threads) do
        thread:Resume()
    end
end

function ThreadManager:RemoveAllThreads()
    for name, _ in pairs(self.m_threads) do
        self:RemoveThread(name)
    end
end

function ThreadManager:Shutdown()
    self:RemoveAllThreads()
end

function ThreadManager:DebugPrint()
    if not Backend.debug_mode then
        return
    end

    for name, thread in pairs(self.m_threads) do
        printf(
            "[%s] running: %s, suspended: %s",
            name,
            thread:IsRunning(),
            thread:IsSuspended()
        )
    end
end

return ThreadManager
