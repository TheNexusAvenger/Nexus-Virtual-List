--Types for Nexus Virtual List.
--!strict

--Manages a GuiInstance and children.
--This can (and will) be reused with different input data.
export type ListEntry<T> = {
    GuiInstance: GuiObject,
    Update: (self: ListEntry<T>, Index: number, Data: T) -> (ListEntry<T>),
    Destroy: (self: ListEntry<T>) -> (),
}

--Constructor function for ListEntry<T>.
--Note: ListEntry<T> does not enforce a constructor.
export type ListEntryConstructor<T> = (InitialIndex: number, InitialData: T) -> (ListEntry<T>)



return true