TimersList
    TimerListItem
        buttons:
            Start|(Stop|Resume)
        onclick:
            TimerInfo
                TimerStats
                TimerHistory?
                    button: Delete
                    button: 
                        Edit
                            onclick:
                                TimerEdit
                                    TimerName
                                    TimerDuration
                                    TimerRepeat?
                                    TimerRepeatInterval?

    button:Create
        onclick: TimerEdit


Timer
    id
    name
    countdown
    status
        ready
        start
        stop
        pause
        resume

TimerCubit
    start
    stop
    pause
    resume
    tick

TimersCubit
    list
    get
    create
    update
    delete

store timer state each x seconds
