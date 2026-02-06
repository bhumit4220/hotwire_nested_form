# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.all
  end

  def show; end

  def new
    @project = Project.new
    @max = params[:max]
    @min = params[:min]
    @limit_behavior = params[:limit_behavior] || 'disable'
    @sortable = params[:sortable]
    @animation = params[:animation]
  end

  def deep_new
    @project = Project.new
  end

  def edit
    @animation = params[:animation]
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name,
                                    tasks_attributes: [:id, :name, :position, :_destroy,
                                                       { subtasks_attributes: %i[id name _destroy] }])
  end
end
