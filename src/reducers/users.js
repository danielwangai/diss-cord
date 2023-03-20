import {createAsyncThunk, createSlice} from "@reduxjs/toolkit";
import {signUp} from "../api/users";

export const createAccount = createAsyncThunk(
    'users/signUp',
    async (thunkAPI, {username}) => {
        return await signUp(username);
    }
);

const initialState = {
    loading: false,
    user: null,
}

export const usersSlice = createSlice({
    name: "users",
    initialState,
    reducers: {
        // signUp: (state, action) => {},
    },
    extraReducers: {
        [createAccount.fulfilled]: (state, {payload}) => {
            state.user = payload;
        },
    }
});

export default usersSlice.reduce;
