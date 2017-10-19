class ProjectContainer extends Component {
  constructor(props) {
    this.socket = new Socket(props.dispatch)
  }

  componentWillMount() {
    const { projectId } = this.props.match.params
    this.socket.joinProject(projectId)
    this.props.dispatch(fetchProject(projectId))
  }

  componentWillUnmount() {
    const { projectId } = this.props.match.params
    this.socket.leaveProject(projectId)
  }

  // ...
