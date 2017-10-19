const initialState = {
  isFetching: true,
  project: null
}

export default function reducer(state = initialState, action) {
  switch (action.type) {
    case REQUEST_PROJECT:
      return {
        ...state,
        isFetching: true
      }

    case RECEIVE_PROJECT:
      return {
        ...state,
        isFetching: false,
        project: action.project
      }

    default:
      return state
  }
}

export const requestProject = () => ({
  type: REQUEST_PROJECT
})

export const receiveProject = (project) => ({
  type: RECEIVE_PROJECT,
  project
})

export const fetchProject = id => (dispatch, getState, { api, schema }) => {
  dispatch(requestProject())

  return api.projects.getById(id)
    .then(response => {
      const project = response.data
      dispatch(receiveProject(project))
      return project
    })
}
