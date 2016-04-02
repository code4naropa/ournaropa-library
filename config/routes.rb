OurnaropaLibrary::Engine.routes.draw do
  
  get '/search', to: 'search#show', as: :search
  
  get '/fetch_results/:school/:query', to: 'search#fetch_results', as: :fetch_results
  
  root 'search#index', as: :home
  
end
