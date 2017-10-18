class ProjectContainer extends Component {
  componentWillMount() {
    const { projectId } = this.props.match.params
    this.props.dispatch(fetchProject(projectId))
  }

  render() {
    const { project } = this.props

    return <div>
      {project.isFetching
        ? <div>Loading...</div>
        : <Project />
      }
    </div>
  }
}

const mapStateToProps = state => ({
  project: state.project
})

export default connect(mapStateToProps)(ProjectContainer)
