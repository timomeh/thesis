class Project extends Component {
  render() {
    <Switch>
      <Route path="/:projectId/build/:buildId" component={BuildDetails} />
      <Route path="/:projectId/history" component={History} />
      <Route path="/:projectId" component={LatestBuilds} />
    </Switch>
  }
}
